Import-Module Microsoft.Graph

# 1. Fetch the token from the active pipeline session specifically for Microsoft Graph
$GraphToken = (Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com").Token

# 2. Convert to SecureString
$SecureToken = ConvertTo-SecureString $GraphToken -AsPlainText -Force

# 3. Connect to Graph
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
    -AccountEnabled $true `
    -PasswordProfile $PasswordProfile

Write-Host "Successfully created user: $($NewUser.UserPrincipalName)" -ForegroundColor Green