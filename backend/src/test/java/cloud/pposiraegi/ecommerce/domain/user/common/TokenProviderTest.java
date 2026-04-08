package cloud.pposiraegi.ecommerce.domain.user.common;

import cloud.pposiraegi.ecommerce.global.auth.jwt.TokenProvider;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.assertj.core.api.AssertionsForClassTypes.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;

class TokenProviderTest {
    private TokenProvider tokenProvider;
    private final Long TEST_USER_ID = 12345L;

    @BeforeEach
    void setUp() {
        // 1. 보내주신 생성자 규격에 맞게 데이터를 준비합니다.
        // Base64로 인코딩된 32바이트 이상의 시크릿 키 (테스트용)
        String testSecretKey = "cHBvc2lyYWVnaS1lY29tbWVyY2UtbXNhLXNlY3JldC1rZXktdGVzdA==";
        long testValidityTime = 1800000L; // 30분

        // 2. @SpringBootTest 대신 직접 생성자를 호출하여 객체를 만듭니다. (가장 확실한 방법)
        tokenProvider = new TokenProvider(testSecretKey);
    }


    @Test
    @DisplayName("유효한 토큰에서 정상적으로 userId를 추출한다")
    void getUserIdFromToken_Success() {
        // given
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime expiresAt = now.plusMinutes(30); // 30분 후 만료 (정상)
        String token = tokenProvider.createAccessToken(TEST_USER_ID, now, expiresAt);

        // when
        Long extractedUserId = tokenProvider.getUserIdFromToken(token);

        // then
        assertThat(extractedUserId).isEqualTo(TEST_USER_ID);
        assertThat(extractedUserId).isNotNull();
    }

    @Test
    @DisplayName("만료된 토큰을 파싱하면 ExpiredJwtException 예외가 발생한다")
    void getUserIdFromToken_ExpiredToken_ThrowsException() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime expiresAt = now.minusMinutes(1);
        String token = tokenProvider.createAccessToken(TEST_USER_ID, now, expiresAt);

        assertThrows(io.jsonwebtoken.ExpiredJwtException.class, () -> {
            tokenProvider.getUserIdFromToken(token);
        });
    }

    @Test
    @DisplayName("서명이나 구조가 잘못된 토큰을 파싱하면 JwtException 예외가 발생한다")
    void getUserIdFromToken_InvalidToken_ThrowsException() {
        String invalidToken = "eyJhbGciOiJIUzI1NiJ9.invalid_payload.invalid_signature";

        assertThrows(io.jsonwebtoken.JwtException.class, () -> {
            tokenProvider.getUserIdFromToken(invalidToken);
        });
    }
}