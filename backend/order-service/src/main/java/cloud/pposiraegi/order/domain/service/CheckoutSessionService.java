package cloud.pposiraegi.order.domain.service;

import cloud.pposiraegi.common.exception.BusinessException;
import cloud.pposiraegi.common.exception.ErrorCode;
import cloud.pposiraegi.order.domain.entity.CheckoutSession;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;

@Service
@RequiredArgsConstructor
public class CheckoutSessionService {
    private final RedisTemplate<String, Object> redisTemplate;
    private static final String REDIS_KEY_PREFIX = "checkout:session:";

    public void saveSession(Long checkoutId, CheckoutSession session, long minutes) {
        redisTemplate.opsForValue().set(REDIS_KEY_PREFIX + checkoutId, session, Duration.ofMinutes(minutes));
    }

    public CheckoutSession getCheckoutSession(Long checkoutId) {
        String redisKey = REDIS_KEY_PREFIX + checkoutId;
        CheckoutSession checkoutSession = (CheckoutSession) redisTemplate.opsForValue().get(redisKey);

        if (checkoutSession == null) {
            throw new BusinessException(ErrorCode.CHECKOUT_NOT_FOUND);
        }

        return checkoutSession;
    }

    public void deleteSession(Long checkoutId) {
        redisTemplate.delete(REDIS_KEY_PREFIX + checkoutId);
    }
}
