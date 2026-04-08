package cloud.pposiraegi.user.domain.user.service;

import cloud.pposiraegi.user.domain.user.dto.UserAddressInfoDto;
import cloud.pposiraegi.user.domain.user.repository.UserAddressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserAddressQueryService {
    private final UserAddressRepository userAddressRepository;

    public UserAddressInfoDto.UserAddressInfo getLastUsedAddress(Long userId) {
        return userAddressRepository.findFirstByUserIdOrderByLastUsedAtDesc(userId)
                .map(UserAddressInfoDto.UserAddressInfo::from)
                .orElse(null);
    }
}
