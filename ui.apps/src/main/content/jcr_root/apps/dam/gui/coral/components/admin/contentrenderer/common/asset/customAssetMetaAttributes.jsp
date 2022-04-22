<%@ page import="com.adobe.granite.ui.components.AttrBuilder" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@include file="/apps/dam/gui/coral/components/admin/contentrenderer/base/customAssetBase.jsp"%>
<%@ page session="false" %><%
    AttrBuilder metaAttrs = (AttrBuilder) request.getAttribute("com.adobe.assets.meta.attributes");

    final String gettyId = request.getAttribute(GETTY_ID) != null ? (String) request.getAttribute(GETTY_ID) : "";
    if (StringUtils.isNotBlank(gettyId)) {
        metaAttrs.add("data-getty-id", gettyId);
    }
%>
