<%--
  ADOBE CONFIDENTIAL

  Copyright 2015 Adobe Systems Incorporated
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
%><%@include file="/libs/granite/ui/global.jsp"%><%
%><%@page import="org.apache.sling.api.resource.Resource,
                  javax.jcr.Node,
                  com.day.cq.dam.api.Asset,
                  org.apache.sling.resource.collection.ResourceCollection"%><%
%><%@taglib prefix="cq" uri="http://www.day.com/taglibs/cq/1.0"%><%
%><%@include file="/libs/dam/gui/coral/components/admin/contentrenderer/base/base.jsp"%><%
%><%@include file="/libs/dam/gui/coral/components/admin/contentrenderer/base/assetBase.jsp"%><%
%><%@include file="/apps/dam/gui/coral/components/admin/contentrenderer/base/customAssetBase.jsp"%><%--###
ASSET Properties
=========

###--%><%
long publishDateInMillis = request.getAttribute(PUBLISH_DATE_IN_MILLIS) != null ? (long) request.getAttribute(PUBLISH_DATE_IN_MILLIS) : -1;
String publishedDate = request.getAttribute(PUBLISHED_DATE) != null ? (String) request.getAttribute(PUBLISHED_DATE) : null;
boolean isDeactivated = request.getAttribute(IS_DEACTIVATED) != null ? (boolean) request.getAttribute(IS_DEACTIVATED) : false;
String publishedBy = request.getAttribute(PUBLISHED_BY) != null ? (String) request.getAttribute(PUBLISHED_BY) : "";
long assetLastModification = request.getAttribute(ASSET_LAST_MODIFICATION) != null ? (long) request.getAttribute(ASSET_LAST_MODIFICATION) : 0;
String lastModified = request.getAttribute(LAST_MODIFIED) != null ? (String) request.getAttribute(LAST_MODIFIED) : "";
int commentsCount = request.getAttribute(COMMENTS_COUNT) != null ? (int) request.getAttribute(COMMENTS_COUNT) : 0;
String status = request.getAttribute(STATUS) != null ? (String) request.getAttribute(STATUS) : "";
boolean isAssetExpired = request.getAttribute(IS_ASSETEXPIRED) != null ? (boolean) request.getAttribute(IS_ASSETEXPIRED) : false;
boolean isSubAssetExpired = request.getAttribute(IS_SUBASSET_EXPIRED) != null ? (boolean) request.getAttribute(IS_SUBASSET_EXPIRED) : false;
String size = request.getAttribute(SIZE) != null ? (String) request.getAttribute(SIZE) : "0.0 B";
String resolution = request.getAttribute(RESOLUTION) != null ? (String) request.getAttribute(RESOLUTION) : "";
double averageRating = request.getAttribute(AVERAGE_RATING) != null ? (double) request.getAttribute(AVERAGE_RATING) : 0.0;
double creativeRating = request.getAttribute(CREATIVE_RATING) != null ? (double) request.getAttribute(CREATIVE_RATING) : 0.0;
long width = request.getAttribute(WIDTH) != null ? (long) request.getAttribute(WIDTH) : 0;
long height = request.getAttribute(HEIGHT) != null ? (long) request.getAttribute(HEIGHT) : 0;
long bytes = request.getAttribute(BYTES) != null ? (long) request.getAttribute(BYTES) : 0;
boolean isCheckedOut = request.getAttribute(IS_CHECKED_OUT) != null ? (boolean) request.getAttribute(IS_CHECKED_OUT) : false;
boolean isMergedTemplate = request.getAttribute(IS_MERGED_PRINT_TEMPLATE) != null ? (boolean) request.getAttribute(IS_MERGED_PRINT_TEMPLATE) : false;
String checkedOutByFormatted = request.getAttribute(CHECKED_OUT_BY_FORMATTED) != null ? (String) request.getAttribute(CHECKED_OUT_BY_FORMATTED) : "";
PublicationStatus publicationStatus = getPublicationStatus(request, i18n);
JSONObject viewSettings = (JSONObject) request.getAttribute(VIEW_SETTINGS);
JSONArray propArr = viewSettings.getJSONArray(VIEW_SETTINGS_PN_PROPS);
List<String> properties = getViewSettingProperties(propArr);
// Temporary fix for CQ-4234527. Remove it once card size adjustment feature is implemented for collection
boolean isContextCollection = false;
Resource contextResource = UIHelper.getCurrentSuffixResource(slingRequest);
if (contextResource != null) {
    if (contextResource.adaptTo(ResourceCollection.class) != null) {
        isContextCollection = true;
    }
}
String dateFormat = viewSettings.getString(VIEW_SETTINGS_PN_DATE_FORMAT);
boolean isStockAsset = request.getAttribute(IS_STOCK_ASSET) != null ? (boolean) request.getAttribute(IS_STOCK_ASSET) : false;

//custom start
final String gettyId = request.getAttribute(GETTY_ID) != null ? (String) request.getAttribute(GETTY_ID) : "";
//custom end
%><coral-card-propertylist>
<% if ((isContextCollection || properties.contains(VIEW_PN_LAST_MODIFICATION)) && publishDateInMillis < assetLastModification) { %>
    <coral-card-property icon="edit" title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Modified")) %>">
        <foundation-time type="datetime" format="<%= xssAPI.encodeForHTMLAttr(dateFormat) %>" value="<%= xssAPI.encodeForHTMLAttr(lastModified) %>"></foundation-time>
    </coral-card-property>
    <% } if ((isContextCollection || properties.contains(VIEW_PN_IS_MERGED_PRINT_TEMPLATE)) && isMergedTemplate) { %>
    <coral-card-property icon="wrench" title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Merged")) %>">
        <%=xssAPI.encodeForHTML(i18n.get("Merged"))%>
    </coral-card-property>
<% } if ((isContextCollection || properties.contains(VIEW_PN_CHECKED_OUT_BY)) && isCheckedOut) { %>
    <coral-card-property icon="lockOn" title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Checked Out By")) %>">
        <%= xssAPI.encodeForHTML(checkedOutByFormatted) %>
    </coral-card-property>
<% }
        String icon = null;
        String briefStatus = "";
        if (publicationStatus.getAction() != null) {
            icon = publicationStatus.getIcon();
            briefStatus = publicationStatus.getBriefStatus();
        } else {
            if (publishedDate != null) {
                icon = isDeactivated ? "globeStrike" : "globe";
            }
        }
        if (icon != null) {


%><%
    if((isContextCollection || properties.contains(VIEW_PN_PUBLISHED_DATE))) {
%><coral-card-property icon="<%= icon %>" title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Asset Publication Status")) %>"><%
    if (!briefStatus.equals("")) {%>
        <coral-card-property-content> <%= i18n.getVar(briefStatus) %></coral-card-property-content>
    <%} else {%>
        <foundation-time type="datetime" format="<%= xssAPI.encodeForHTMLAttr(dateFormat) %>" value="<%= xssAPI.encodeForHTMLAttr(publishedDate) %>"></foundation-time>
    <%}%>
</coral-card-property>
    <% } %>
<% } if ((isContextCollection || properties.contains(VIEW_PN_COMMENTS_COUNT)) && commentsCount > 0) { %>
<coral-card-property icon="comment" title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Comments")) %>"><%= xssAPI.encodeForHTML(Integer.toString(commentsCount)) %></coral-card-property>
<% } if((isContextCollection || properties.contains(VIEW_PN_STATUS))) {
    if (status.equals("approved")) { %>
    <coral-card-property class="status approved" icon="thumbUp" title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Approved")) %>"></coral-card-property>
    <% } else if (status.equals("rejected")) { %>
    <coral-card-property class="status rejected" icon="thumbDown" title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Rejected")) %>"></coral-card-property>
    <% } else if (status.equals("changesRequested") || status.equals("pending")) { %>
    <coral-card-property class="status changesrequested" icon="pending" title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Changes Requested")) %>"></coral-card-property>
<% } } if ( (isContextCollection || properties.contains(VIEW_PN_IS_ASSETEXPIRED)) && (isAssetExpired || isSubAssetExpired)) { %>
<coral-card-property class="expirystatus" icon="flag" data-is-asset-expired="<%= isAssetExpired %>" data-is-sub-asset-expired="<%= isSubAssetExpired %>" title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Expired")) %>"></coral-card-property>
<% } if((isContextCollection || properties.contains(VIEW_PN_SIZE))) {%>
<coral-card-property data-size="<%= bytes%>" title="<%= xssAPI.encodeForHTMLAttr(i18n.get("size")) %>"><%= xssAPI.encodeForHTML(size) %></coral-card-property>
<% } %>
</coral-card-propertylist>
<%  if ((isContextCollection || properties.contains(VIEW_PN_RESOLUTION) || properties.contains(VIEW_PN_AVERAGE_RATING) || isStockAsset) && (resolution.length() > 0 ||
        averageRating > 0)) {  %>
<coral-card-propertylist class="<%= isStockAsset ? "stock-asset-card-propertylist" : "" %>">
<%  if ((isContextCollection || properties.contains(VIEW_PN_RESOLUTION)) && resolution.length() > 0) { %>
<coral-card-property icon="<%= isStockAsset ? "stock" : "" %>" title="<%= xssAPI.encodeForHTMLAttr(i18n.get("resolution")) %>" data-width="<%= width%>"><%= xssAPI.encodeForHTML(resolution)%></coral-card-property>
<% } %>
<%-- custom start --%>
<%  if (StringUtils.isNotBlank(gettyId)) { %>
    <coral-card-property icon="stock" title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Getty ID")) %>"><%= xssAPI.encodeForHTML(gettyId) %></coral-card-property>
<% } %>
<%-- custom end --%>
<%
    if((isContextCollection || properties.contains(VIEW_PN_AVERAGE_RATING))) {
        Resource ratingConfRes = resourceResolver.getResource("/etc/dam/creativeratingconfig");
        Config cfg = new Config(ratingConfRes);
        boolean creativeRatingEnabled = cfg.get("creativeRatingEnabled", false);
        double shownRating = 0.0;
        if (creativeRatingEnabled) {
            shownRating = creativeRating;
        } else {
            shownRating = averageRating;
        }
    if (shownRating > 0) {
int averageCharacterstic = (int) shownRating;
double averageMantissa = shownRating - averageCharacterstic;
double sizeinrem = 0.75;

double widthMantissa = averageMantissa * sizeinrem;
StringBuilder altText = new StringBuilder("");

if (averageCharacterstic == 1) {
    altText.append(i18n.get("{0} star", "", averageCharacterstic));
} else {
    altText.append(i18n.get("{0} stars", "", averageCharacterstic));
}
%><coral-card-property class="rating expired" title="<%=averageRating%>" role="img" aria-label="<%=altText.toString()%>">
    <div class = "rating-background" style = "color: rgba(0, 0, 0, 0.57);">
        <coral-icon icon="starStroke" alt="" size="XS"></coral-icon>
        <coral-icon icon="starStroke" alt="" size="XS"></coral-icon>
        <coral-icon icon="starStroke" alt="" size="XS"></coral-icon>
        <coral-icon icon="starStroke" alt="" size="XS"></coral-icon>
        <coral-icon icon="starStroke" alt="" size="XS"></coral-icon>
    </div>
    <div class = "rating-foreground" style = "color: #4178cd;margin-top: -1.0625rem;">
        <%
        for (int i = 0 ; i < averageCharacterstic ; i++) {
            %>
            <coral-icon icon="starFill" size="XS" style="overflow: hidden;" alt=""></coral-icon>
            <%
        }
        if (averageMantissa > 0) {
            String style = "overflow: hidden; width:" + widthMantissa + "rem;";
            %>
            <coral-icon icon="starFill" size="XS" style="<%=style%>" alt=""></coral-icon>
            <%
        }
        %>
    </div>
</coral-card-property>
<% } } %>
</coral-card-propertylist>
<% } %>