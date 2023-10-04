#Install module azure-identity azure-mgmt-compute


from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient
import json

def get_instance_metadata():
    credential = DefaultAzureCredential()
    compute_client = ComputeManagementClient(credential, '3120408b-74d6-4408-a4fb-5b5a7d977000')
    instance_metadata = compute_client.virtual_machines.get('terraform-machine', 'terraform-machine')
    instance_metadata_dict = {
        "os_type": instance_metadata.storage_profile.os_disk.os_type,

    }

    return instance_metadata_dict
if __name__ == "__main__":
    instance_metadata = get_instance_metadata()
    json_output = json.dumps(instance_metadata, indent=4)

    print(json_output)