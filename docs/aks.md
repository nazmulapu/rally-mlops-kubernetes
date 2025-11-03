# AKS Notes

## Check available VM SKUs
```bash
az vm list-skus --location northeurope --output table
```

## Grant role-assignment permissions to Terraform SP
The Terraform Service Principal must be able to create role assignments. Grant `User Access Administrator` at the subscription scope:

```bash
az role assignment create \
  --assignee 14bc63e1-9633-4cee-984c-9d021d05db2b \
  --role "User Access Administrator" \
  --scope /subscriptions/fea043f7-8550-4f4b-9ed5-5cf07fe5065a
```
