# Digital Bank #

Official repository documentation for the Digital Bank Global Initiative.

# Table of Contents
1. [Changelog](#change-log)
2. [Deploy](#deploy)
3. [Process](#process)
4. [Manual Steps](#manual-steps)

## Change Log

##### V3.0.0 - Back to the future
###### 09/05/2017
* Switched repository to TEST environment ORG
* New metadata clean + fetch
* Several weeks worth of developments, including (in no particular order):
    * [FEATURE] Social Studio custom interaction, you can now create opportunities directly through social studio, progressing through an email process
    * [FEATURE] Push Notification management, ability to send push notification to the mobile app based on a contact's device
    * [ENHANCEMENT] New dashboards and homepage with many different new reports
    * [ENHANCEMENT] New communities along with new article and knowledge management
    * [ENHANCEMENT] Updated data generation to allow for Revenues and data ownership randomization

##### V2.1.4_r2 - Gender Issues
###### 13/04/2017
* Renamed Gender__c custom field to avoid conflicts with FSC (really?)
* Added sharing rules for several object to manage branches
* Added really poorly made booking bug unmanaged triggers
* New process builder to automatically populate risk related fields on contacts on creation
* Several new fields and layouts
* Definitively removed flowdefinitions from the package.xml
* USer grouping to manage visibilities by branches

##### V2.1.4 - Risky McRiskFace
###### 11/04/2017
* Added risk management:
    * Added FICO to contact
    * Added multiple fields on account to perform risk evaluations
* Added Marketing Cloud connected app
* Added case flieds for mulesoft integration

##### V2.1.3
###### 07/04/2017
* Added support for case + service cloud
* Added support for branches

##### V2.1.3
###### 07/04/2017
* Added recent transactions related list to accounts with segmentation by category

##### V2.1.2_r2
###### 06/04/2017
* Transactions update:
    * transactions are now linked to FA primary owner too to have a key transaction related list on account
    * process builder updated to populate the transaction account owner
    * added transaction related list to account
* Removed application metadata form package.xml, has issues with nav lightning applications + CTI

##### V2.1.2 - Panicked Pinoy
###### 05/04/2017
* New transaction management:
    * Updated whole transaction data model to match iOS Digital Bank transactional data
    * New process builder to match new fields
    * Rebuilt transactionApi to support new fields dynamically, just put all DigitalBank transaction fields into the JSON!
* Hotfix for "new" button on related lists

##### V2.1.1
###### 05/04/2017
* New metadata version 39.0
* New build.xml, fixes deploy with hardcoded usernames in *.site metadata
* Fix: Opp fetching logic

##### V2.1.0._r3
###### 04/04/2017
* Removed **Financial Account** and **Role** columns on Opportunity related list in 720
* Fix: dymanic fetch of Opportunity Record Type while creating a new Opp in the custom related list

##### V2.1.0 r2
###### 03/04/2017
* Updated layouts
* Updated flow versions
    * new version for financial account creation on Opp closing

##### V2.1.0
###### 31/03/2017
* **fixed** "new" button on Opportunity related list, still need an hardcoded id for record type
* creation of Financial Account on opportunity win

##### V2.0.0
###### 31/03/2017
* **new feature**: transaction management, it is now possibile for external systems to integrate with DigitalBank anc create new transactions between financial accounts.
    * New transactions move money between financial accouts, and if above a certain threshold will also generate a relevant alert on receiving products!
* added required fields on Contact for iOS app interface

## Deploy
The list of relevant metadata is contained into [package.xml](src/package.xml).

## Process
Deploy process description goes here

* Add every needed FSC custom object manually to the package.xml, this is not done by default from MavensMate but is required if you added custom fields, validation rules, etc... to a FSC object.
* Clone any managed layout that has been modified/you intend to modify. This is necessary to have it in the list of deployable metadatas and to make it visible in Mavensmate.
    * Apply any necessary Record Type assignment to the new layouts.
* If present, remove the the following rows:
    * Account.object

                ...
                <lookupPhoneDialogsAdditionalFields>00N46000005AlND</lookupPhoneDialogsAdditionalFields>
                <lookupPhoneDialogsAdditionalFields>00N46000005AlN8</lookupPhoneDialogsAdditionalFields>
                ...

        This is a bug in SFDC metadata for some layout types, that reference hardcoded Ids which are obviously not going to work into other orgs.

* If the Digital Bank_ app is not available, be sure to check if it's activated as a lightning app
* Adjust any Field Level Security settings that might miss from the Admin/System Administrator profile (this is actually a bug in the profile naming).
* Always check for Process Builder Flows version in target environment. Flows are notoriously bugged and might need an additional manual deploy.
* Manually place CTI_Phone_UtilityBar in the DigitalBank app and set up CTI as needed
* Deploy Groups and Global Value Sets manually and beforehand, this is  aknown issue with salesforce deployments.
