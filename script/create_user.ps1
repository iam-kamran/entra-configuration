Import-Module Microsoft.Graph

# 1. Ask Azure CLI for the Graph token and explicitly trim any hidden newlines (\r\n)
$RawToken = (az account get-access-token --resource https://graph.microsoft.com --query accessToken -o tsv).Trim()

# 2. Sanity check to prevent empty tokens from passing through
if ([string]::IsNullOrWhiteSpace($RawToken)) {
    Write-Error "Failed to retrieve the access token. Pipeline login may have failed."
    exit 1
}

# 3. Secure the token and connect
$SecureToken = ConvertTo-SecureString $RawToken -AsPlainText -Force
Connect-MgGraph -AccessToken $SecureToken

Write-Host "Successfully authenticated to Microsoft Graph via OIDC!" -ForegroundColor Green

# 4. Construct the user profile payload
$PasswordProfile = @{
    Password = "TempPassword123!"
    ForceChangePasswordNextSignIn = $true
}

# 5. Create the user
$NewUser = New-MgUser -DisplayName "Test Pipeline User" `
    -UserPrincipalName "testpipeline@yourdomain.com" `
    -MailNickname "testpipeline" `
    -AccountEnabled:$true `
    -PasswordProfile $PasswordProfile

Write-Host "Successfully created user: $($NewUser.UserPrincipalName)" -ForegroundColor Green
