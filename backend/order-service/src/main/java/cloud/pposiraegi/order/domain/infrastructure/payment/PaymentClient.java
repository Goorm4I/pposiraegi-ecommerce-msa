package cloud.pposiraegi.order.domain.infrastructure.payment;

import cloud.pposiraegi.order.domain.dto.PaymentDto;

import java.math.BigDecimal;

public interface PaymentClient {
    PaymentDto.PaymentResponse confirm(String paymentKey, String orderNumber, BigDecimal amount);
}
