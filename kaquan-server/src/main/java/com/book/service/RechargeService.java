package com.book.service;

import com.book.common.Result;
import com.book.dto.RechargeRequest;
import com.book.entity.RechargeOrder;
import com.book.entity.User;
import com.book.mapper.RechargeOrderMapper;
import com.book.mapper.UserMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * 充值服务
 */
@Slf4j
@Service
public class RechargeService {

    @Resource
    private UserMapper userMapper;

    @Resource
    private RechargeOrderMapper rechargeOrderMapper;

    @Transactional(rollbackFor = Exception.class)
    public Result<?> recharge(Integer userId, RechargeRequest req) {
        // 1. 查询用户
        User user = userMapper.selectById(userId);
        if (user == null) {
            return Result.error("用户不存在");
        }

        BigDecimal amount = req.getAmount();
        BigDecimal balanceBefore = user.getBalance() != null ? user.getBalance() : BigDecimal.ZERO;
        BigDecimal balanceAfter = balanceBefore.add(amount);

        // 2. 生成订单
        RechargeOrder order = new RechargeOrder();
        order.setUserId(userId);
        order.setOrderNo(generateOrderNo());
        order.setAmount(amount);
        order.setPayMethod(req.getPayMethod());
        order.setStatus("success");  // 模拟支付成功
        order.setBalanceBefore(balanceBefore);
        order.setBalanceAfter(balanceAfter);
        order.setRemark("用户充值 ¥" + amount);
        rechargeOrderMapper.insert(order);

        // 3. 原子更新余额
        int rows = userMapper.addBalance(userId, amount);
        if (rows <= 0) {
            throw new RuntimeException("更新余额失败，请重试");
        }

        log.info("充值成功: userId={}, orderNo={}, amount={}, before={}, after={}",
                userId, order.getOrderNo(), amount, balanceBefore, balanceAfter);

        return Result.ok(order.getOrderNo());
    }

    private String generateOrderNo() {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        String random = String.format("%06d", (int) (Math.random() * 1000000));
        return "R" + timestamp + random;
    }
}
