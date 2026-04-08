package cloud.pposiraegi.ecommerce.domain.order.dto;

import java.math.BigDecimal;

public class PaymentDto {
    public record PaymentResponse(
            String status,
            String paymentKey,
            String orderNumber,
            BigDecimal amount
    ) {
    }
}
