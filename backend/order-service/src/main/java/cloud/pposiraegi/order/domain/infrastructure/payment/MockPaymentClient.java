package cloud.pposiraegi.order.domain.infrastructure.payment;

import cloud.pposiraegi.order.domain.dto.PaymentDto;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

@Component
@Profile({"dev", "local", "test", "prod"})
public class MockPaymentClient implements PaymentClient {
    @Override
    public PaymentDto.PaymentResponse confirm(String paymentKey, String orderNumber, BigDecimal amount) {
        return new PaymentDto.PaymentResponse("DONE", paymentKey, orderNumber, amount);
    }
}
