<%@ page import="org.apache.sling.api.resource.ResourceUtil" %>
<%@ page import="org.apache.sling.api.resource.ValueMap" %>
<%@include file="/libs/dam/gui/coral/components/admin/contentrenderer/base/init/assetBase.jsp"%>
<%@include file="/apps/dam/gui/coral/components/admin/contentrenderer/base/customAssetBase.jsp"%>
<%
    final ValueMap metadataVM = ResourceUtil.getValueMap(metadataResc);
    final String gettyId = metadataVM.get("ns1:AssetID", String.class);

    if (StringUtils.isNotBlank(gettyId)) {
        request.setAttribute(IS_GETTY_ASSET, true);
        request.setAttribute(GETTY_ID, gettyId);
    }
%>