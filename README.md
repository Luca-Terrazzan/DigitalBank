# Digital Bank #

# Table of Contents
1. [Deploy](#deploy)
2. [Process](#process)
3. [Manual Steps](#manual-steps)

Official repository documentation for the Digital Bank Global Initiative.

## Deploy
The list of relevant metadata is contained into [package.xml](src/package.xml).

## Process
Deploy process description goes here

* Add every needed FSC custom object manually to the package.xml, this is not done by default from MavensMate but is required if you added custom fields, validation rules, etc... to a FSC object.
* Clone any managed layout that has been modified/you intend to modify. This is necessary to have it in the list of deployable metadatas and to make it visible in Mavensmate.
    * Apply any necessary assignment to the new layouts.
* If present, remove the the following rows:
    * Account.object

                ...
                <lookupPhoneDialogsAdditionalFields>00N46000005AlND</lookupPhoneDialogsAdditionalFields>
                <lookupPhoneDialogsAdditionalFields>00N46000005AlN8</lookupPhoneDialogsAdditionalFields>
                ...

        This is a bug in SFDC metadata for some layout types, that reference hardcoded Ids which are obviously not going to work into other orgs.

* If the Digital Bank_ app is not available, be sure to check if it's activated as a lightning app
* Adjust any Field Level Security settings that might miss from the Admin/System Administrator profile (this is actually a bug in the profile naming).


## Manual Steps
Each manual step required to fix the deploy afterwards goes here

add manually FinServ objects to package.xml if you added some custom fields to them

Activate bitbucket-pipelines.yml