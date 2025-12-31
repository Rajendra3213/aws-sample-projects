# How to use 
```bash
aws apigateway create-api-key --name "test-key" --enabled
aws apigateway create-usage-plan --name "test-plan" --api-stages apiId=67egqfhr64,stage=prod
aws apigateway create-usage-plan-key --usage-plan-id {plan-id} --key-type API_KEY --key-id {key-id}
```

```bash
curl -X GET \
  "https://67egqfhr64.execute-api.us-east-1.amazonaws.com/prod/get" \
  -H "x-api-key: {your-api-key}"
```

```bash
aws cognito-idp admin-create-user \
  --user-pool-id us-east-1_3QSCyLF7u \
  --username testuser \
  --temporary-password TempPass123! \
  --message-action SUPPRESS
```

```bash
aws cognito-idp admin-initiate-auth \
  --user-pool-id us-east-1_3QSCyLF7u \
  --client-id 7d7trbucreqrjfi9tagf559jup \
  --auth-flow ADMIN_NO_SRP_AUTH \
  --auth-parameters USERNAME=testuser,PASSWORD=TempPass123!
```


```bash
curl -X POST \
  "https://67egqfhr64.execute-api.us-east-1.amazonaws.com/prod/put" \
  -H "Authorization: Bearer test-token" \
  -H "Content-Type: application/json" \
  -d '{"ID":"123","FirstName":"John","Age":30}'
```

```bash
curl -X POST \
  "https://67egqfhr64.execute-api.us-east-1.amazonaws.com/prod/delete/123" \
  -H "Authorization: {cognito-access-token}"
```