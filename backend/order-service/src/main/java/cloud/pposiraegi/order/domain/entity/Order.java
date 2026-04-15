package cloud.pposiraegi.order.domain.entity;

import cloud.pposiraegi.common.entity.BaseUpdatedEntity;
import cloud.pposiraegi.common.exception.BusinessException;
import cloud.pposiraegi.common.exception.ErrorCode;
import cloud.pposiraegi.order.domain.enums.OrderStatus;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Getter
@Entity
@Table(name = "orders")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Order extends BaseUpdatedEntity {
    @Id
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "order_number", unique = true, nullable = false, length = 25)
    private String orderNumber;

    @Column(name = "checkout_id", nullable = false)
    private Long checkoutId;

    @Column(name = "total_amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal totalAmount;

    @Column(name = "shipping_address_id")
    private Long shippingAddressId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private OrderStatus status;

    @Builder
    public Order(Long id, Long userId, Long checkoutId, String orderNumber, BigDecimal totalAmount, Long shippingAddressId) {
        this.id = id;
        this.userId = userId;
        this.checkoutId = checkoutId;
        this.orderNumber = orderNumber;
        this.totalAmount = totalAmount;
        this.status = OrderStatus.PENDING_PAYMENT;
    }

    public void updateStatus(OrderStatus newStatus) {
        if (newStatus == null) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE);
        }

        if (this.status == OrderStatus.CANCELED) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE);
        }

        this.status = newStatus;
    }
}