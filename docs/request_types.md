# Request Services available through Orangelight

* Recap Physical Delivery Request (Offsite Materials)
    * Materials Managed in Alma Base Status: Item in Place
    * Materials Managed in SCSB Status: Available
* Recap Electronic Delivery Request (scan a selection shelved at ReCAP on demand)
    * Materials Managed in Alma Base Status: Item in Place
    * Materials Managed in SCSB Status: Available
* Annex Phyiscal Delivery Request (Offsite Materials)
    * Materials Managed in Alma Base Status: Item in Place
    * Materials without a base status and which are not in a process type (Alma Physical Titles Only)
* Annex Electronic Delivery Request (scan a selection shelved at Annex on demand) 
    * Materials Managed in Alma Base Status: Item in Place
    * Materials without a base status and which are not in a process type (Alma Physical Titles Only)
    * Annex Electronic Delivery Requests are placed in ILLiad.
* On Order Requests 
    * Items that are in the Alma "Acquisition" Process Type. These are items ordered for our shelves but have not yet arrived.
    * On order requests are emailed to the Library where the items will be permeantly shelved at. For ReCAP items that are in ReCAP Alma Library these emails go to Firestone Circulation. 
* In Process Requests 
    * Items in the Alma "In Process" Process Type and the Alma Work Order Type "Acquisitions and Cataloging". These requests expedite processing of items that are here on campus  have not yet been prepared to be placed on shelf. Materials have an Alma Base Status of "Item Not in Place".
    * In Process requests are emailed to the Library where the items will be permeantly shelved at. For ReCAP items that are in ReCAP Alma Library these emails go to Firestone Circulation. 
* Pick-up Service (request an item for pick-up that is shelved at a campus library)
     * Materials Managed in Alma Base Status: Item in Place
     * Materials without a base status and which are not in a process type (Alma Physical Titles Only) - pick-up requests for these materials are sent via email to circ staff. 
* Digitization Request (scan a selection from an item shelved on campus on demand) 
    * Materials Managed in Alma Base Status: Item in Place
    * Materials without a base status and which are not in a process type (Alma Physical Titles Only)
    * Digitization requests for campus materials are placed through ILLiad.
* Clancy Physical Delivery Request (Offsite Marquand Items at the Clancy Facility)
    * Items in Marquand locations that are not at ReCAP or or are not Supervised Use Materials (items that are in Special Collections. In bibdata's holding_location table the flag aeon=true)
    * Materials Managed in Alma Base Status: Item in Place
    * Materials without a base status and which are not in a process type (Alma Physical Titles Only) - Request sent via email to Marquand staff. 
* Clancy Electronic Delivery Request (scan a selection shelved at Clancy on demand)
    * Items in Marquand locations that are not at ReCAP or are not Supervised Use Materials (items that are in Special Collections. In bibdata's holding_location table the flag aeon=true)
    * Requests are placed in ILLiad
* Resource Sharing Services (Request an item from another library via Borrow Direct or InterLibrary Loan (Illiad)
    * Any item that has a process type that is not Acquisition or In Process and has an Alma Base Status of "Item Not In Place". For items that are in the "In Process" type any items in a work order type that is NOT "Acquisitions and Cataloging". 
    * If a match is found requests are placed in Borrow Direct's Relais system; otherwise requests are placed in ILLiad. 
* Reading Room Request (request supervised use materials for viewing in a Special Collections Reading Room)
    * Reading Room Requests are placed in Aeon
    * Any item in special collections location (aeon = true in the bibdata holding_location table)