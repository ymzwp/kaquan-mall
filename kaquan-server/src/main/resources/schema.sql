-- ============================================================
-- 卡券商城 (coupon_mall) 数据库建表脚本
-- 基于项目实体类、Mapper XML/注解、Service 业务逻辑分析生成
-- 生成日期: 2026-06-18
-- ============================================================

CREATE DATABASE IF NOT EXISTS coupon_mall DEFAULT CHARSET utf8mb4;
USE coupon_mall;

-- ============================================================
-- 1. 前台用户表 (user)
-- 来源: User.java, UserMapper.xml, UserDao.java
-- ============================================================
CREATE TABLE IF NOT EXISTS `user` (
    `id`            INT(11)         NOT NULL AUTO_INCREMENT  COMMENT '用户主键',
    `username`      VARCHAR(64)     NOT NULL                 COMMENT '登录账号',
    `password`      VARCHAR(255)    NOT NULL                 COMMENT '密码（BCrypt/MD5加密）',
    `nick_name`     VARCHAR(64)     DEFAULT '新注册用户'     COMMENT '用户昵称',
    `phone`         VARCHAR(20)     DEFAULT NULL             COMMENT '手机号',
    `email`         VARCHAR(128)    DEFAULT NULL             COMMENT '邮箱',
    `avatar`        VARCHAR(500)    DEFAULT ''               COMMENT '头像图片地址',
    `balance`       DECIMAL(10,2)   NOT NULL DEFAULT 0.00    COMMENT '账户余额',
    `points`        INT(11)         NOT NULL DEFAULT 0       COMMENT '云梦豆',
    `member_level`  VARCHAR(20)     NOT NULL DEFAULT 'normal' COMMENT '会员等级: normal/bronze/silver/gold',
    `invite_code`   VARCHAR(20)     DEFAULT NULL             COMMENT '邀请码（格式: XJ+5位数字）',
    `invited_by`    INT(11)         DEFAULT NULL             COMMENT '邀请人用户ID',
    `create_time`   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`),
    UNIQUE KEY `uk_invite_code` (`invite_code`),
    KEY `idx_invited_by` (`invited_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='前台用户表';

-- ============================================================
-- 2. 商品分类表 (category)
-- 来源: Category.java, CateDao.java
-- 支持三级层级: parentId=0 为一级分类
-- ============================================================
CREATE TABLE IF NOT EXISTS `category` (
    `id`            INT(11)         NOT NULL AUTO_INCREMENT  COMMENT '分类主键',
    `cate_name`     VARCHAR(100)    NOT NULL                 COMMENT '分类名称',
    `icon`          VARCHAR(500)    DEFAULT ''               COMMENT '分类图标URL',
    `parent_id`     INT(11)         NOT NULL DEFAULT 0       COMMENT '父分类ID，0为一级分类',
    `level`         TINYINT(4)      NOT NULL DEFAULT 1       COMMENT '层级: 1=一级 2=二级 3=三级',
    `sort_order`    INT(11)         NOT NULL DEFAULT 0       COMMENT '排序（越小越靠前）',
    PRIMARY KEY (`id`),
    KEY `idx_parent_id` (`parent_id`),
    KEY `idx_level_sort` (`level`, `sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品分类表（三级层级）';

-- ============================================================
-- 3. 卡券商品表 (goods)
-- 来源: Goods.java, GoodsDao.java, AdminDao.java
-- ============================================================
CREATE TABLE IF NOT EXISTS `goods` (
    `id`            INT(11)         NOT NULL AUTO_INCREMENT  COMMENT '商品主键',
    `cate_id`       INT(11)         NOT NULL                 COMMENT '所属分类ID',
    `goods_name`    VARCHAR(200)    NOT NULL                 COMMENT '商品名称',
    `price`         DECIMAL(10,2)   NOT NULL DEFAULT 0.00    COMMENT '商品价格',
    `stock`         INT(11)         NOT NULL DEFAULT 0       COMMENT '库存数量',
    `goods_img`     VARCHAR(500)    DEFAULT ''               COMMENT '商品主图URL',
    `info`          VARCHAR(500)    DEFAULT ''               COMMENT '商品简介',
    `detail_imgs`   TEXT            DEFAULT NULL             COMMENT '详情图片URL（逗号分隔多个）',
    `status`        TINYINT(4)      NOT NULL DEFAULT 1       COMMENT '状态: 1=上架 0=下架',
    PRIMARY KEY (`id`),
    KEY `idx_cate_id` (`cate_id`),
    KEY `idx_status` (`status`),
    CONSTRAINT `fk_goods_cate` FOREIGN KEY (`cate_id`) REFERENCES `category` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='卡券商品表';

-- ============================================================
-- 4. 订单表 (orders)
-- 来源: Orders.java, OrderDao.java, AdminDao.java, AdminController.java
-- ============================================================
CREATE TABLE IF NOT EXISTS `orders` (
    `id`              INT(11)         NOT NULL AUTO_INCREMENT  COMMENT '订单主键',
    `user_id`         INT(11)         NOT NULL                 COMMENT '下单用户ID',
    `goods_id`        INT(11)         NOT NULL                 COMMENT '商品ID',
    `order_price`     DECIMAL(10,2)   NOT NULL DEFAULT 0.00    COMMENT '订单金额',
    `account_number`  VARCHAR(50)     DEFAULT ''               COMMENT '充值账号（QQ号/手机号）',
    `pay_method`      VARCHAR(20)     NOT NULL DEFAULT 'alipay' COMMENT '支付方式: alipay/wechat/balance',
    `status`          VARCHAR(20)     NOT NULL DEFAULT 'completed' COMMENT '订单状态: pending/completed/refunded',
    `create_time`     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '下单时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_goods_id` (`goods_id`),
    KEY `idx_create_time` (`create_time`),
    CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT `fk_orders_goods` FOREIGN KEY (`goods_id`) REFERENCES `goods` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

-- ============================================================
-- 5. 充值订单表 (recharge_order)
-- 来源: RechargeOrder.java, RechargeDao.java, RechargeController.java
-- 使用软删除 (deleted 字段)
-- ============================================================
CREATE TABLE IF NOT EXISTS `recharge_order` (
    `id`              BIGINT(20)      NOT NULL AUTO_INCREMENT  COMMENT '充值订单主键',
    `user_id`         INT(11)         NOT NULL                 COMMENT '用户ID',
    `order_no`        VARCHAR(30)     NOT NULL                 COMMENT '订单号（格式: R+时间戳+6位随机数）',
    `amount`          DECIMAL(10,2)   NOT NULL DEFAULT 0.00    COMMENT '充值金额',
    `pay_method`      VARCHAR(20)     NOT NULL DEFAULT 'alipay' COMMENT '支付方式',
    `status`          VARCHAR(20)     NOT NULL DEFAULT 'success' COMMENT '订单状态: success/failed',
    `balance_before`  DECIMAL(10,2)   NOT NULL DEFAULT 0.00    COMMENT '充值前余额',
    `balance_after`   DECIMAL(10,2)   NOT NULL DEFAULT 0.00    COMMENT '充值后余额',
    `remark`          VARCHAR(500)    DEFAULT ''               COMMENT '备注',
    `deleted`         TINYINT(1)      NOT NULL DEFAULT 0       COMMENT '逻辑删除: 0=正常 1=已删除',
    `create_time`     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_order_no` (`order_no`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_deleted` (`deleted`),
    CONSTRAINT `fk_recharge_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='充值订单表';

-- ============================================================
-- 6. 用户签到表 (user_sign)
-- 来源: UserSign.java, SignDao.java, SignServiceImpl.java
-- ============================================================
CREATE TABLE IF NOT EXISTS `user_sign` (
    `id`            INT(11)         NOT NULL AUTO_INCREMENT  COMMENT '签到主键',
    `user_id`       INT(11)         NOT NULL                 COMMENT '用户ID',
    `sign_date`     DATE            NOT NULL                 COMMENT '签到日期',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_date` (`user_id`, `sign_date`),
    CONSTRAINT `fk_sign_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户签到表';

-- ============================================================
-- 7. 优惠券表 (coupon)
-- 来源: Coupon.java, CouponDao.java
-- ============================================================
CREATE TABLE IF NOT EXISTS `coupon` (
    `id`            INT(11)         NOT NULL AUTO_INCREMENT  COMMENT '优惠券主键',
    `title`         VARCHAR(200)    NOT NULL                 COMMENT '券名称',
    `amount`        DECIMAL(10,2)   NOT NULL DEFAULT 0.00    COMMENT '优惠金额',
    `min_amount`    DECIMAL(10,2)   NOT NULL DEFAULT 0.00    COMMENT '最低消费金额',
    `stock`         INT(11)         NOT NULL DEFAULT 0       COMMENT '库存数量',
    `status`        TINYINT(4)      NOT NULL DEFAULT 1       COMMENT '状态: 1=上架 0=下架',
    `create_time`   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_status_stock` (`status`, `stock`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='优惠券表';

-- ============================================================
-- 8. 用户优惠券领取记录表 (user_coupon)
-- 来源: CouponDao.java（联表查询 user_coupon JOIN coupon）
-- ============================================================
CREATE TABLE IF NOT EXISTS `user_coupon` (
    `id`            INT(11)         NOT NULL AUTO_INCREMENT  COMMENT '记录主键',
    `user_id`       INT(11)         NOT NULL                 COMMENT '用户ID',
    `coupon_id`     INT(11)         NOT NULL                 COMMENT '优惠券ID',
    `status`        TINYINT(4)      NOT NULL DEFAULT 0       COMMENT '使用状态: 0=未使用 1=已使用',
    `create_time`   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '领取时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_coupon_id` (`coupon_id`),
    UNIQUE KEY `uk_user_coupon` (`user_id`, `coupon_id`),
    CONSTRAINT `fk_uc_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_uc_coupon` FOREIGN KEY (`coupon_id`) REFERENCES `coupon` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户优惠券领取记录表';

-- ============================================================
-- 9. 后台管理员表 (admin)
-- 来源: Admin.java, AdminDao.java, AdminServiceImpl.java
-- ============================================================
CREATE TABLE IF NOT EXISTS `admin` (
    `id`            INT(11)         NOT NULL AUTO_INCREMENT  COMMENT '管理员主键',
    `username`      VARCHAR(64)     NOT NULL                 COMMENT '管理员账号',
    `password`      VARCHAR(255)    NOT NULL                 COMMENT '密码（BCrypt/MD5加密）',
    `create_time`   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='后台管理员表';

-- ============================================================
-- 10. 站内通知表 (sys_notify)
-- 来源: SysNotify.java, NotifyDao.java
-- ============================================================
CREATE TABLE IF NOT EXISTS `sys_notify` (
    `id`            INT(11)         NOT NULL AUTO_INCREMENT  COMMENT '通知主键',
    `title`         VARCHAR(200)    NOT NULL                 COMMENT '通知标题',
    `content`       TEXT            NOT NULL                 COMMENT '通知内容',
    `status`        TINYINT(4)      NOT NULL DEFAULT 1       COMMENT '状态: 1=显示 0=隐藏',
    `create_time`   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_status_time` (`status`, `create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='站内通知表';

-- ============================================================
-- 11. 邀请奖励记录表 (invite_reward)
-- 来源: InviteDao.java, UserServiceImpl.java
-- ============================================================
CREATE TABLE IF NOT EXISTS `invite_reward` (
    `id`            INT(11)         NOT NULL AUTO_INCREMENT  COMMENT '记录主键',
    `inviter_id`    INT(11)         NOT NULL                 COMMENT '邀请人用户ID',
    `invitee_id`    INT(11)         NOT NULL                 COMMENT '被邀请人用户ID',
    `reward`        VARCHAR(100)    NOT NULL                 COMMENT '奖励内容（如: 100云梦豆）',
    `create_time`   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_inviter_id` (`inviter_id`),
    KEY `idx_invitee_id` (`invitee_id`),
    CONSTRAINT `fk_invite_inviter` FOREIGN KEY (`inviter_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_invite_invitee` FOREIGN KEY (`invitee_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='邀请奖励记录表';

-- ============================================================
-- 可选：插入默认管理员账号
-- 密码 admin123 的 BCrypt 哈希（建议部署后立即修改）
-- ============================================================
-- INSERT INTO admin (username, password) VALUES ('admin', '$2a$10$...');
