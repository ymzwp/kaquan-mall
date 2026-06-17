package com.book.controller;

import com.book.common.Result;
import com.book.dto.RechargeRequest;
import com.book.service.RechargeService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import javax.servlet.http.HttpSession;
import javax.validation.Valid;

/**
 * 充值接口
 */
@RestController
@RequestMapping("/recharge")
public class RechargeController {

    @Resource
    private RechargeService rechargeService;

    /**
     * 创建充值订单
     * POST /recharge/create
     * Body: { "amount": 100.00, "payMethod": "alipay" }
     */
    @PostMapping("/create")
    public Result<?> create(@Valid @RequestBody RechargeRequest req, HttpSession session) {
        Object userIdObj = session.getAttribute("userId");
        if (userIdObj == null) {
            return Result.error(401, "请先登录");
        }
        Integer userId = (Integer) userIdObj;
        return rechargeService.recharge(userId, req);
    }
}
