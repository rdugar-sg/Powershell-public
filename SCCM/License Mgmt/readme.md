https://blog.ctglobalservices.com/configuration-manager-sccm/kea/asset-intelligence-3rd-party-software-utility/


Asset Intelligence 3rd. party software utility
Configuration Manager 2007 and 2012 allows you to import licens information from a CSV file. The data are shown in the License 15A – General License Reconciliation Report. The problem for many is, that it’s often a bit to difficult to create the CSV file in the correct format. Highly inspired by the CM2007 AILW utility we decided to create our own tool and make it work for both Configuration Manager 2007 and the upcoming 2012 version.

You can download the utility here.

Configuring the utility
Once you have downloaded our utility you have to:

Copy CT-AILW.exe to C:\Program Files\Coretech\AILW\ CT-AILW.exe (you need to create the folder manually).
Copy e1db6caa-40cb-49f0-a744-21ca930b419f\e1db6caa-40cb-49f0-a744-21ca930b419f.xml to <D>:\Program Files\Microsoft Configuration Manager\Admin\e1db6caa-40cb-49f0-a744-21ca930b419f\e1db6caa-40cb-49f0-a744-21ca930b419f.xml to <D>:\Program Files\Microsoft Configuration Manager\ Admin Console\XmlStorage\Extensions\Actions\ e1db6caa-40cb-49f0-a744-21ca930b419f\e1db6caa-40cb-49f0-a744-21ca930b419f.xml (notice, you need to create the Actions folder manually).
Restart the Configuration Manager Console.
How it works
Using the tool is pretty easy, all you need to know is the name, vendor and version of the application. Those information can be found in the Resource Explorer.

Restart the Configuration Manager administrator console and navigate to the Asset and Compliance workspace.
Click Edit 3rd Party Licenses on the Ribbon. 
image
Type the name of the Configuration Manager site server and click Connect to Database.
image
Make sure you are on the Edit tab. Scroll down to the end and enter a new product:
image
Select the Commit tab and click Commit to SCCM.
image

Run the report License 15A – General License Reconciliation Report
image

Credits goes to Claus Codam, who has been the main developer on this project.
