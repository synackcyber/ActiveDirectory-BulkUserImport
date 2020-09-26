# Import active directory module for running AD cmdlets
Import-Module ActiveDirectory
  
# Store the data from ADDSNewUsers.csv in the $ADUsers variable. Create the directory at the non-root C:\ drive to avoid permissions issue. 
$ADUsers = Import-Csv C:\CSVimport\ADDSNewUsers.csv

# Define UPN. Add your information in below variables
$UPN = "yourdomain.com"
#Define default Proxy address- This will set the primary (good for ADConnect)
$proxydomainname = "@yourdomain.com"
#Variable to set SMTP - All CAPS will set the primary in the proxyAddresses AD variable.
$SMTP1= "SMTP:"

# Loop through each row containing user details in the CSV file
foreach ($User in $ADUsers) {

    #Read user data from each field in each row and assign the data to a variable as below
    $username = $User.username
    $password = $User.password
    $firstname = $User.firstname
    $lastname = $User.lastname
    $initials = $User.initials
    $OU = $User.ou #This field refers to the OU the user account is to be created in
    $email = $User.email
    $streetaddress = $User.streetaddress
    $city = $User.city
    $zipcode = $User.zipcode
    $state = $User.state
    $telephone = $User.telephone
    $jobtitle = $User.jobtitle
    $company = $User.company
    $department = $User.department
    #$proxyAddresses = $User.proxyAddresses
    $SMTP1 = $SMTP1 + $User.proxyAddresses + $proxydomainname

    # Check to see if the user already exists in AD
    if (Get-ADUser -F { SamAccountName -eq $username }) {
        
        # If user does exist, give a warning
        Write-Warning "A user account with username $username already exists in Active Directory."
    }
    else {

        # User does not exist then proceed to create the new user account
        # Account will be created in the OU provided by the $OU variable read from the CSV file
        #Not all fields are required to be filled out in the CSV file.
        New-ADUser `
            -SamAccountName $username `
            -UserPrincipalName "$username@$UPN" `
            -Name "$firstname $lastname" `
            -GivenName $firstname `
            -Surname $lastname `
            -Initials $initials `
            -Enabled $True `
            -DisplayName "$firstname, $lastname" `
            -Path $OU `
            -City $city `
            -PostalCode $zipcode `
            -Company $company `
            -State $state `
            -StreetAddress $streetaddress `
            -OfficePhone $telephone `
            -EmailAddress $email `
            -Title $jobtitle `
            -Department $department `
            -AccountPassword (ConvertTo-secureString $password -AsPlainText -Force) -ChangePasswordAtLogon $True
        
        #Add primary UPN to the user ProxyAddress field
        Get-ADUser $user.username | set-aduser -Add @{Proxyaddresses="$SMTP1"}

        # If user is created, show message.
        Write-Host "The user account $username is created." -ForegroundColor Cyan
    }
}