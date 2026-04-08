package cloud.pposiraegi.ecommerce.domain.order.infrastructure.payment;

import cloud.pposiraegi.ecommerce.domain.order.dto.PaymentDto;

import java.math.BigDecimal;

public interface PaymentClient {
    PaymentDto.PaymentResponse confirm(String paymentKey, String orderNumber, BigDecimal amount);
}
