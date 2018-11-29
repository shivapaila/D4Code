public class ProductCartItemWrapper {
	public String sku;
    public Integer qnty;
    
    public ProductCartItemWrapper(String skuId, Integer quantity){
        this.sku = skuId;
        this.qnty = quantity;
    }
}