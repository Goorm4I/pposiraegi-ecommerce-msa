package cloud.pposiraegi.user.domain.user.dto;

import cloud.pposiraegi.common.validator.ValidPhoneNumber;
import cloud.pposiraegi.user.domain.user.entity.User;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class UserDto {
    public record RegisterRequest(
            @Email @NotBlank String email,
            @NotBlank String password,
            @NotBlank @Size(min = 2, max = 20) String name,
            String nickname,
            @NotBlank @ValidPhoneNumber String phoneNumber
    ) {
    }

    public record SimpleResponse(
            Long id,
            String nickname,
            String profileImageUrl
    ) {
        public static SimpleResponse from(User user) {
            return new SimpleResponse(
                    user.getId(),
                    user.getNickname(),
                    user.getProfileImageUrl()
            );
        }
    }
}
