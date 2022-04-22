<%@ page session="false" %>
<%@include file="/apps/dam/gui/coral/components/admin/contentrenderer/base/customAssetBase.jsp"%>
<%
    String actionRels = (String) request.getAttribute("actionRels");

    final boolean isGettyAsset = request.getAttribute(IS_GETTY_ASSET) != null && (boolean) request.getAttribute(IS_GETTY_ASSET);
    if (isGettyAsset) {
        actionRels = actionRels.concat(" my-damadmin-admin-actions-getty-viewexternal-activator");
    }

    request.setAttribute("actionRels", actionRels);
%>