package model;

public class CartItem {
    private Product product;
    private int quantity;

    public CartItem() {
    }

    public CartItem(Product product, int quantity) {
        this.product = product;
        this.quantity = quantity;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    // Tiện ích lấy nhanh thông tin của Product
    public int getProductId() {
        return product != null ? product.getProductId() : 0;
    }

    public String getProductName() {
        return product != null ? product.getProductName() : "";
    }

    public double getUnitPrice() {
        return product != null ? product.getPrice() : 0.0;
    }

    public String getUnit() {
        return product != null ? product.getUnit() : "kg";
    }

    public String getImageUrl() {
        return product != null ? product.getImageUrl() : "";
    }

    public int getStockQuantity() {
        return product != null ? product.getStockQuantity() : 0;
    }

    // Tính thành tiền cho từng món (SubTotal)
    public double getSubTotal() {
        if (product == null) return 0.0;
        return product.getPrice() * quantity;
    }
}
