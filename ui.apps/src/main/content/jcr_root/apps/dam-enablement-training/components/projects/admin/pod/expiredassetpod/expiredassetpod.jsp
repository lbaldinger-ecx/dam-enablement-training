<%--
  ADOBE CONFIDENTIAL

  Copyright 2013 Adobe Systems Incorporated
  All Rights Reserved.

  NOTICE:  All information contained herein is, and remains
  the property of Adobe Systems Incorporated and its suppliers,
  if any.  The intellectual and technical concepts contained
  herein are proprietary to Adobe Systems Incorporated and its
  suppliers and may be covered by U.S. and Foreign Patents,
  patents in process, and are protected by trade secret or copyright law.
  Dissemination of this information or reproduction of this material
  is strictly forbidden unless prior written permission is obtained
  from Adobe Systems Incorporated.
--%><%
%><%@page session="false"
          import="com.adobe.cq.projects.api.Project,
                com.adobe.cq.projects.api.ProjectLink,
                com.adobe.granite.ui.components.AttrBuilder,
                com.day.cq.dam.api.Asset,
                com.day.cq.dam.api.Rendition,
                com.day.cq.dam.commons.util.UIHelper,
                org.apache.commons.lang.StringUtils,
                org.apache.sling.api.resource.Resource,
                org.apache.sling.api.resource.ValueMap,
                javax.jcr.Node,
                javax.jcr.RepositoryException,
                javax.jcr.Session,
                javax.jcr.security.AccessControlManager,
                javax.jcr.security.Privilege,
                java.util.ArrayList,
                java.util.HashSet,
                java.util.Iterator,
                java.util.List, java.util.Set,
                org.apache.jackrabbit.JcrConstants,
                org.apache.jackrabbit.util.Text" %>
<%@ page import="com.day.cq.dam.api.DamConstants" %>
<%@ page import="com.day.cq.dam.commons.util.DamUtil" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.time.Instant" %>
<%@ page import="com.day.cq.search.PredicateGroup" %>
<%@ page import="com.day.cq.search.QueryBuilder" %>
<%@ page import="com.day.cq.search.Query" %>
<%@ page import="com.day.cq.search.result.SearchResult" %>
<%
%><%@include file="/libs/granite/ui/global.jsp"%><%
    AccessControlManager acm = null;
    try {
        acm = resourceResolver.adaptTo(Session.class).getAccessControlManager();
    } catch (RepositoryException e) {
        log.error("Unable to get access manager", e);
    }

    List<String> permissions = new ArrayList<String>();
    permissions.add("cq-project-admin-actions-open-activator");

    if (hasPermission(acm, resource, Privilege.JCR_REMOVE_NODE)) {
        permissions.add("cq-projects-admin-actions-delete-link-activator");
    }

    boolean canConfigureAssetPod = hasPermission(acm, resource, Privilege.JCR_ADD_CHILD_NODES);

    ProjectLink projectLink = resource.adaptTo(ProjectLink.class);
    Project project = projectLink.getProject();
    Resource projectResource = project.adaptTo(Resource.class);
    ValueMap vm = resource.adaptTo(ValueMap.class);

    String assetPath = vm.get("assetPath", DamConstants.MOUNTPOINT_ASSETS);
    String title = i18n.getVar(vm.get("jcr:title", "Expired Assets"));
    String xssTitle = xssAPI.filterHTML(title);

    AttrBuilder qfAttrs = new AttrBuilder(request, xssAPI);

    boolean isError = false;
    int totalCount = 0;
    String projectDetailsHref = "";
    String assetEditHref = "";
    String truncatedPath = "";
    Set<String> imagePathSet = new HashSet<String>();
    String emptyMessage = i18n.get("This folder contains no assets");

    Resource targetResource = resourceResolver.getResource(assetPath);
    if (targetResource != null) {
        QueryBuilder queryBuilder = sling.getService(QueryBuilder.class);
        Map<String, String> predicates = new HashMap<>();
        predicates.put("path", assetPath);
        predicates.put("type", "dam:Asset");
        predicates.put("1_daterange.property", "jcr:content/metadata/prism:expirationDate");
        predicates.put("1_daterange.upperBound", Instant.now().toString());
        Query query = queryBuilder.createQuery(PredicateGroup.create(predicates), resourceResolver.adaptTo(Session.class));
        query.setStart(0);
        query.setHitsPerPage(20);
        SearchResult result = query.getResult();

        int includedCount = 0;

        for (Iterator<Resource> resultIter = result.getResources(); resultIter.hasNext();) {
            Resource childResource = resultIter.next();
            Asset asset = childResource.adaptTo(Asset.class);
            if (asset != null) {
                if (includedCount++ < MAX_ITEMS) {
                    imagePathSet.add(getAssetUrl(childResource, asset, 48));
                }
                totalCount++;
            }
        }

        assetEditHref = "/assets.html"+ assetPath;
        projectDetailsHref = request.getContextPath() + "/projects/details.html" + projectResource.getPath();

        truncatedPath = assetPath;
        if ( assetPath.startsWith("/content/dam") ) {
            truncatedPath = assetPath.substring("/content/dam".length());
            if (StringUtils.isBlank( truncatedPath ) ) {
                // if the path is only /content/dam then keep it all
                truncatedPath = assetPath;
            } else {
                // otherwise prepend with ... to indicate the truncation
                truncatedPath = "..." + truncatedPath;
            }
        }
    } else {
        isError = true;
        emptyMessage = i18n.get("Path not found");
        qfAttrs.addClass("error");
    }

    if (imagePathSet.size() == 0) {
        qfAttrs.addClass("empty");
    }
    int cardWeight = vm.get("cardWeight", 0);


    List<String> actionRels = new ArrayList<String>();
    actionRels.add("foundation-collection-item-activator");
    if (hasPermission(acm, resource, Privilege.JCR_REMOVE_NODE)) {
        actionRels.add("cq-projects-admin-actions-delete-activator");
    }

    request.setAttribute("projectLinkResource", resource);
    request.setAttribute("assetHref", xssAPI.getValidHref(Text.escapePath(assetEditHref)));
    request.setAttribute("assetPath", assetPath);
    request.setAttribute("truncatedPath", truncatedPath);
    request.setAttribute("imagePathSet", imagePathSet);
    request.setAttribute("totalCount", totalCount);
%>

<sling:include path="/apps/dam-enablement-training/projects/templates/my-project/dashboard/default/expired-asset/jcr:content"/><%
    request.setAttribute("projectLinkResource", null);
%>

<%! public static final int MAX_ITEMS = 16;

    String getAssetUrl(Resource assetResource, Asset asset, int iconSize) {
        String thumbnailUrl = null;
        if ( assetResource != null && asset != null ) {
            Rendition thumbnailRendition = UIHelper.getBestfitRendition(asset, iconSize);

            if(thumbnailRendition != null) {
                try {
                    thumbnailUrl = asset.getPath() + "/jcr:content/renditions/" + thumbnailRendition.getName();
                } catch(Exception e) {
                    // LOGGER.info("Unable to get thumbnail rendition information", e);
                }
            } else {
                //default thumbnail
                thumbnailUrl = assetResource.getPath() + ".thumb."+iconSize+"."+iconSize+".png";
            }
        }
        return thumbnailUrl;
    }

    boolean hasPermission(AccessControlManager acm, Resource resource, String privilege) {
        try {
            if (acm != null) {
                Privilege p = acm.privilegeFromName(privilege);
                return acm.hasPrivileges(resource.getPath(), new Privilege[]{p});
            }
        } catch (RepositoryException e) {
            // if we have a error then we will return false.
        }
        return false;
    }
%>