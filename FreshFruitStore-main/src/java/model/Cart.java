package model;

import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.Map;

public class Cart {
    // Dùng LinkedHashMap để giữ nguyên thứ tự các món khi thêm vào giỏ
    private Map<Integer, CartItem> items;

    public Cart() {
        items = new LinkedHashMap<>();
    }

    public Map<Integer, CartItem> getItemMap() {
        return items;
    }

    public Collection<CartItem> getItems() {
        return items.values();
    }

    // 1. Thêm sản phẩm vào giỏ hàng (kiểm tra tồn kho)
    public boolean addItem(Product product, int quantity) {
        if (product == null || quantity <= 0) return false;

        int pid = product.getProductId();
        int maxStock = product.getStockQuantity();

        if (items.containsKey(pid)) {
            CartItem current = items.get(pid);
            int newQty = current.getQuantity() + quantity;
            if (newQty > maxStock) {
                newQty = maxStock; // Chặn không cho vượt quá số lượng tồn kho
            }
            current.setQuantity(newQty);
        } else {
            int initialQty = Math.min(quantity, maxStock);
            if (initialQty > 0) {
                items.put(pid, new CartItem(product, initialQty));
            } else {
                return false; // Hết hàng
            }
        }
        return true;
    }

    // 2. Cập nhật số lượng của một mặt hàng
    public boolean updateQuantity(int productId, int quantity, int maxStock) {
        if (!items.containsKey(productId)) return false;

        if (quantity <= 0) {
            removeItem(productId);
            return true;
        }

        int finalQty = quantity;
        if (maxStock > 0 && finalQty > maxStock) {
            finalQty = maxStock;
        }

        items.get(productId).setQuantity(finalQty);
        return true;
    }

    // 3. Xóa một sản phẩm khỏi giỏ hàng
    public void removeItem(int productId) {
        items.remove(productId);
    }

    // 4. Xóa rỗng toàn bộ giỏ hàng
    public void clear() {
        items.clear();
    }

    // 5. Kiểm tra giỏ hàng có rỗng không
    public boolean isEmpty() {
        return items.isEmpty();
    }

    // 6. Tính tổng số lượng mặt hàng (hiển thị lên icon badge)
    public int getTotalQuantity() {
        int total = 0;
        for (CartItem item : items.values()) {
            total += item.getQuantity();
        }
        return total;
    }

    // 7. Tính tổng tiền toàn bộ đơn hàng
    public double getTotalAmount() {
        double total = 0.0;
        for (CartItem item : items.values()) {
            total += item.getSubTotal();
        }
        return total;
    }
}
