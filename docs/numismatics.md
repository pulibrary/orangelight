# Numismatics

## Indexing

A coin is indexed in the [Catalog](https://catalog.princeton.edu/) (Orangelight) when a coin or issue is updated and published in [Figgy](https://figgy.princeton.edu/).
The indexing happens in seconds. see: [Rabbitmq-Sneakers](./rabbitmq-sneakers.md)  

## Visible changes related to the application and the environment 

* Web applications: [Figgy](https://github.com/pulibrary/figgy), [Catalog](https://github.com/pulibrary/orangelight) 
* Environments: production, staging  
* Changes that happen in [Figgy production](https://figgy.princeton.edu/?f%5Bhuman_readable_type_ssim%5D%5B%5D=Coin&q=) will be visible in [Catalog production](https://catalog.princeton.edu/?f%5Bformat%5D%5B%5D=Coin)
* Changes that happen in [Figgy staging](https://figgy-staging.princeton.edu/?f%5Bhuman_readable_type_ssim%5D%5B%5D=Coin&q=) will be visible in [Catalog staging](https://catalog-staging.princeton.edu/?f%5Bformat%5D%5B%5D=Coin)
* Changes that happen in [Catalog production](https://catalog.princeton.edu/?f%5Bformat%5D%5B%5D=Coin) will be visible in [Catalog production](https://catalog.princeton.edu/?f%5Bformat%5D%5B%5D=Coin)
* Changes that happen in [Catalog staging](https://catalog-staging.princeton.edu/?f%5Bformat%5D%5B%5D=Coin) will be visible in [Catalog staging](https://catalog-staging.princeton.edu/?f%5Bformat%5D%5B%5D=Coin)
* To see the changes both applications need to be deployed to the specific environment accordingly.

## Stakeholders review

* Any change - usually for testing purposes -  that happens in the staging environment can be reviewed in [Figgy staging](https://figgy-staging.princeton.edu/?f%5Bhuman_readable_type_ssim%5D%5B%5D=Coin&q=) or [Catalog staging](https://catalog-staging.princeton.edu/?f%5Bformat%5D%5B%5D=Coin) or in both.   

* Any change that happens in the production environment can be reviewed in [Figgy production](https://figgy.princeton.edu/?f%5Bhuman_readable_type_ssim%5D%5B%5D=Coin&q=) or [Catalog production](https://catalog.princeton.edu/?f%5Bformat%5D%5B%5D=Coin) or in both.  
* To see the changes both applications need to be deployed to the specific environment accordingly.

## Communication

* Numismatics PO: @kelea99  
* Slack channels: #orangelight, #figgy, #catalog
* Questions regarding [Figgy](https://figgy.princeton.edu/): contact in slack @dls  
* Questions regarding [Catalog](https://catalog.princeton.edu/): contact in slack @dacs  
* Coordinate a stakeholder review: contact @kelea99  





 


