package cloud.pposiraegi.user.domain.auth.repository;

import cloud.pposiraegi.user.domain.auth.entity.UserRefreshTokenEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRefreshTokenRepository extends JpaRepository<UserRefreshTokenEntity, Long> {
    Optional<UserRefreshTokenEntity> findByTokenValue(String tokenValue);

    void deleteByUserId(Long userId);

    Optional<UserRefreshTokenEntity> findByUserId(Long userId);
}
