In the record page we build in the DOM an element with class 'document-thumbnail' where we also include the bibid in a data-attribute:
```
<div class="document-thumbnail" data-bib-id="99106565893506421">
  <div class="default"></div>
</div>
```

1. If the specific record id exists as a scanned resource in figgy:
Orangelight uses the bibid from the data attribute and invokes an async graphql call against figgy.
   * For better performance we filter the resource that has no FileSet.
   * If graphql returns from figgy one resource, it uses the iiif manifest and builds a UV viewer in a div element with id 'viewer-container'. This element is included in a div element with id 'view'.
   * If graphql returns from figgy two resources then we display two viewers with an incremental id, viewer_container and viewer-container_1. Both of these viewer containers are included in  the div element with id='view'. example record: https://catalog.princeton.edu/catalog/9946018083506421    

   * If there is a thumbnail url, it builds a thumbnail. The existence of a thumbnail will add a content icon in the thumbnail and wrap it in an href="viewer-container". Clicking this content icon navigates the user to the UV viewer container with id=viewer-container'. example record: https://catalog.princeton.edu/catalog/9970446223506421 

2. If the record id is a related record https://catalog.princeton.edu/catalog/9947826143506421:
* We use the 'electronic_access_1display' field and we filter the related ids from the included catalog domain urls. We add in the DOM a new div element with an incremental div id='view_<incremental_number>" and class 'document-thumbnail'. Orangelight invokes an async graphql against figgy and returns the resources.

3. Available Online section:
* We use the 'electronic_access_1display' field to display anchor text 'Digital Content', 'Selected images' etc. with the catalog domain link. When a viewer exists clicking this link will navigate the user to the viewer section.
* In the electronic_access_1_display we build the catalog domain urls by using the figgy_ark_cache. This is happening during indexing. 

4. Viewer for CDL item
* Similar to step 1, if there is a scanned resource in Figgy, Orangelight returns the viewer. CDL items are accessible only through CAS and for specific patron groups; this is handled in Figgy. Figgy will do a check https://github.com/pulibrary/figgy/blob/main/app/services/cdl/eligible_item_service.rb#L4 to see if the specific item is on cdl. If the item is on cdl it will allow the user to charge or hold it.

_Notes: The rake task to update the figgy_ark_cache errors. The figgy_ark_cache has not been updated since voyager and still includes voyager ids. As a result the catalog domain urls that are structured and indexed during indexing time in the 'electronic_access_1display' have the voyager id. The user clicks on the Digital Content and a new record page will open because it tries to resolve the voyager id to an alma id.


