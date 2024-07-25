# Set-AllVMAutoShutdown
Enable or Disalbed for all AutoShutdown for all VMs in an Azure subscription.


## Usage

- **Clone repo**
    ```sh
    git clone https://github.com/abotelhofilho/Set-AllVMAutoShutdown
    cd .\Set-AllVMAutoShutdown\
    ```

- **dot load it into your powershell session**
    ```sh
    . .\func_Set-AllVMAutoShutdown.ps1
    ```

- **Run the function**
    ```sh
    Set-AllVMAutoShutdown -Status Enabled -subscriptionName acme-prod
    ```
