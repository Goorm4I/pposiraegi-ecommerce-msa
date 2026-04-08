package cloud.pposiraegi.ecommerce.domain.user.common;

import cloud.pposiraegi.ecommerce.domain.common.PhoneNumber;
import cloud.pposiraegi.ecommerce.domain.user.user.entity.User;
import cloud.pposiraegi.ecommerce.domain.user.user.repository.UserRepository;
import cloud.pposiraegi.ecommerce.global.auth.jwt.TokenProvider;
import com.github.f4b6a3.tsid.TsidFactory;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@SpringBootTest
public class TokenGenerationTest {

    @Autowired
    private TokenProvider tokenProvider;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private TsidFactory tsidFactory;
    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private EntityManager entityManager; // 영속성 컨텍스트 관리를 위해 주입

    @Test
    @Transactional
    void generateTokensForTest() throws IOException {
        int userCount = 10000;
        int batchSize = 500; // 한 번에 처리할 단위
        File file = new File("tokens.csv");

        String dummyHash = passwordEncoder.encode("password");
        List<User> userBatch = new ArrayList<>();

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
            for (int i = 0; i < userCount; i++) {
                Long userId = tsidFactory.create().toLong();

                User user = User.builder()
                        .id(userId)
                        .email("local_test_%d@pposiraegi.cloud".formatted(i))
                        .nickname("local_test_%d".formatted(i))
                        .passwordHash(dummyHash)
                        .name("테스터")
                        .phoneNumber(new PhoneNumber("010-1234-%04d".formatted(i % 10000)))
                        .build();

                userBatch.add(user);

                // 설정한 batchSize 단위로 DB 저장 및 메모리 비우기
                if (userBatch.size() >= batchSize) {
                    userRepository.saveAll(userBatch);
                    userRepository.flush();
                    entityManager.clear(); // 1차 캐시(영속성 컨텍스트) 초기화
                    userBatch.clear();
                }

                String token = tokenProvider.createAccessToken(userId, LocalDateTime.now(), LocalDateTime.now().plusHours(1));
                writer.write(token);
                writer.newLine();
            }

            // 마지막으로 남은 데이터 처리
            if (!userBatch.isEmpty()) {
                userRepository.saveAll(userBatch);
            }
        }
    }
}
