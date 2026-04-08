package cloud.pposiraegi.ecommerce.domain.order.infrastructure.payment;

import cloud.pposiraegi.ecommerce.domain.order.dto.PaymentDto;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

@Component
@Profile({"dev", "local", "test"})
public class MockPaymentClient implements PaymentClient {
    @Override
    public PaymentDto.PaymentResponse confirm(String paymentKey, String orderNumber, BigDecimal amount) {
        return new PaymentDto.PaymentResponse("DONE", paymentKey, orderNumber, amount);
    }
}
