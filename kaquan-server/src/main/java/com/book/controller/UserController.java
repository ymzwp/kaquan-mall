package com.book.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.book.common.Result;
import com.book.entity.User;
import com.book.mapper.UserMapper;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import javax.servlet.http.HttpSession;
import java.util.Map;

/**
 * 用户接口
 */
@RestController
@RequestMapping("/user")
public class UserController {

    @Resource
    private UserMapper userMapper;

    /**
     * 获取当前登录用户信息
     */
    @PostMapping("/getLogin")
    public Result<?> getLogin(HttpSession session) {
        Object userId = session.getAttribute("userId");
        if (userId == null) {
            return Result.error(401, "未登录");
        }
        User user = userMapper.selectById((Integer) userId);
        if (user == null) {
            session.invalidate();
            return Result.error(401, "用户不存在");
        }
        user.setPassword(null);
        return Result.ok(user);
    }

    /**
     * 登录
     * Body: { "username": "user1", "password": "123456" }
     */
    @PostMapping("/login")
    public Result<?> login(@RequestBody Map<String, String> body, HttpSession session) {
        String username = body.get("username");
        String password = body.get("password");

        User user = userMapper.selectOne(
                new LambdaQueryWrapper<User>()
                        .eq(User::getUsername, username)
        );
        if (user == null) {
            return Result.error("用户名不存在");
        }
        // 实际项目应使用 BCrypt 比较
        if (!password.equals(user.getPassword())) {
            return Result.error("密码错误");
        }

        session.setAttribute("userId", user.getId());

        user.setPassword(null);
        return Result.ok(user);
    }

    /**
     * 退出登录
     */
    @PostMapping("/logout")
    public Result<?> logout(HttpSession session) {
        session.invalidate();
        return Result.ok();
    }
}
