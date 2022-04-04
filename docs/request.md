# Requests
## Integrations
* [Borrow Direct](https://catalog.princeton.edu/borrow-direct)
  Can cancel requests by connecting to the URL above
  * Used to request items from partners.  Only connects for unavailable items that include an ISBN number
* Illiad
  Can cancel request from [orangelight](https://catalog.princeton.edu/account/digitization_requests)
  * Used to request unavailable items that are not borrow direct eligible.
  * Used to request Digitizations
* [Alma](https://princeton.alma.exlibrisgroup.com/discovery/account?vid=01PRI_INST:Services&lang=EN&section=overview)
  can cancel request by connecting to the URL above
  * Used to request pick-up of available items on the shelf
  * Holds are created for ReCAP Items when physical delivery is requested
  * Holds are requested for Marquand Offsite (clancy) items when physical or digital item is requested
* Clancy (ciasoft)
  All requests on qa and staging go to a test system, so they do not need to be canceled
  * Used to request items from Marquand
    1. Check if items are present in Clancy (all Marquand items)
    1. If present both digital and pick-up request require the physical item to be sent to Princeton campus
* ReCAP
   **Can Not cancel requests sent to ReCAP**
  * Used to request physical pickup of off site materials
    **A hold in Alma is also created for a physical request.  This can and should be canceled during testing.**
  * Used to request a digital copy of off site materials
    **Test should be put in as many fields as possible in a test request.  Usually they note the test and do not do the digitization**
