/****** v1 | Indicates what all operations are possible with the external data source | 12/15/2017 | Rucha (Perficient) */
/*              that provides order and their line item information                                         */

global with sharing class OrdersDataSourceProvider extends DataSource.Provider{

    //This method facilitates authentication to the external data source 
    override global List<DataSource.AuthenticationCapability>
        getAuthenticationCapabilities() {
        List<DataSource.AuthenticationCapability> capabilities =
            new List<DataSource.AuthenticationCapability>();
        capabilities.add(
            DataSource.AuthenticationCapability.ANONYMOUS);
        return capabilities;
    }

    //This method specifies what operations are possible on the external data source
    //Currently only query and search are faciliated
    override global List<DataSource.Capability> getCapabilities(){
        List<DataSource.Capability> capabilities = new
            List<DataSource.Capability>();
        capabilities.add(DataSource.Capability.ROW_QUERY);
        capabilities.add(DataSource.Capability.SEARCH);
        return capabilities;
    }

    //This method creates an instance of the adaptor class
    override global DataSource.Connection getConnection(
    DataSource.ConnectionParams connectionParams) {
        return new CustomAdaptorforOrderExternalDataSource(connectionParams);
    }
}