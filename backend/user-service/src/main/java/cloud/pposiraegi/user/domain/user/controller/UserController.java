package cloud.pposiraegi.user.domain.user.controller;

import cloud.pposiraegi.common.dto.ApiResponse;
import cloud.pposiraegi.user.domain.user.dto.UserDto;
import cloud.pposiraegi.user.domain.user.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;

    @PostMapping
    public ApiResponse<UserDto.SimpleResponse> registerUser(@Valid @RequestBody UserDto.RegisterRequest request) {
        UserDto.SimpleResponse response = userService.registerUser(request);
        return ApiResponse.success(response);
    }

    @GetMapping("/{id}")
    public ApiResponse<UserDto.SimpleResponse> getUser(@PathVariable Long id) {
        UserDto.SimpleResponse response = userService.getUser(id);
        return ApiResponse.success(response);
    }
}
