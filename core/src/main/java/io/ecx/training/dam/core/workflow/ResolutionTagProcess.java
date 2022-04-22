package io.ecx.training.dam.core.workflow;

import java.util.Map;
import java.util.TreeMap;

import org.apache.commons.lang3.StringUtils;
import org.apache.sling.api.resource.ModifiableValueMap;
import org.apache.sling.api.resource.Resource;
import org.apache.sling.api.resource.ResourceResolver;
import org.osgi.service.component.annotations.Component;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.adobe.granite.workflow.PayloadMap;
import com.adobe.granite.workflow.WorkflowException;
import com.adobe.granite.workflow.WorkflowSession;
import com.adobe.granite.workflow.exec.WorkItem;
import com.adobe.granite.workflow.exec.WorkflowProcess;
import com.adobe.granite.workflow.metadata.MetaDataMap;
import com.day.cq.dam.api.DamConstants;

@Component(
  service = WorkflowProcess.class,
  property = {
    "process.label=" + "DAM Enablement Training - Add Resolution Tag to Asset"
  }
)
public class ResolutionTagProcess implements WorkflowProcess {

    private static final Logger logger = LoggerFactory.getLogger(ResolutionTagProcess.class);

    @Override
    public void execute(final WorkItem workItem, final WorkflowSession workflowSession, final MetaDataMap processArguments) throws WorkflowException {
        try {
            final ResourceResolver resourceResolver = workflowSession.adaptTo(ResourceResolver.class);
            final String assetPath = this.getAssetPathFromPayload(workItem);
            if (assetPath != null) {
                final Resource assetResource = resourceResolver.getResource(assetPath);
                final Resource metadataResource = resourceResolver.getResource(assetResource, "jcr:content/metadata");
                final ModifiableValueMap metadataMVM = metadataResource.adaptTo(ModifiableValueMap.class);

                final long imageResolution = this.getImageResolution(metadataMVM);

                if (imageResolution > 0) {
                    final TreeMap<Long, String> resolutionTagMapping = this.getResolutionTagMapping(processArguments);
                    final String biggestResolutionTag = this.getBiggestResolutionTag(imageResolution, resolutionTagMapping);

                    if (biggestResolutionTag != null) {
                        logger.info("Adding resolution tag {} to asset {}", biggestResolutionTag, assetPath);
                        metadataMVM.putIfAbsent("my:resolution", biggestResolutionTag);
                    }
                }
            }
        } catch (final RuntimeException e) {
            throw new WorkflowException("Error while adding resolution tag to asset", e);
        }
    }

    private String getAssetPathFromPayload(final WorkItem workItem) {
        return StringUtils.equals(workItem.getWorkflowData().getPayloadType(), PayloadMap.TYPE_JCR_PATH) ? workItem.getWorkflowData().getPayload().toString() : null;
    }

    private long getImageResolution(final ModifiableValueMap metadataMVM) {
        final long imageWidth = metadataMVM.get(DamConstants.TIFF_IMAGEWIDTH, metadataMVM.get(DamConstants.EXIF_PIXELYDIMENSION, 0L));
        final long imageHeight = metadataMVM.get(DamConstants.TIFF_IMAGELENGTH, metadataMVM.get(DamConstants.EXIF_PIXELXDIMENSION, 0L));
        return imageWidth * imageHeight;
    }

    /**
     * Mapping will be given in the form of:
     *
     * 720x576=properties:resolution/sd
     * 1080x720=properties:resolution/hd
     * 1920x1080=properties:resolution/fhd
     * 2560x1440=properties:resolution/qhd
     * 3840x2160=properties:resolution/4k
     * 7680x4320=properties:resolution/8k
     */
    private TreeMap<Long, String> getResolutionTagMapping(final MetaDataMap processArguments) {
        final TreeMap<Long, String> mapping = new TreeMap<>();

        final String[] processArgs = StringUtils.split(processArguments.get("PROCESS_ARGS", String.class), "\r\n");
        for (final String processArg : processArgs) {
            final String[] arg = StringUtils.split(processArg, '=');
            if (arg.length == 2) {
                final long width = Long.parseLong(StringUtils.substringBefore(arg[0], "x"));
                final long height = Long.parseLong(StringUtils.substringAfter(arg[0], "x"));
                final long resolution = width * height;
                final String tagId = arg[1];
                mapping.put(resolution, tagId);
            }
        }

        return mapping;
    }

    private String getBiggestResolutionTag(final long imageResolution, final TreeMap<Long, String> resolutionTagMapping) {
        String biggestResolutionTag = null;

        for (final Map.Entry<Long, String> mappingEntry : resolutionTagMapping.entrySet()) {
            if (imageResolution >= mappingEntry.getKey()) {
                biggestResolutionTag = mappingEntry.getValue();
            }
        }

        return biggestResolutionTag;
    }

}
