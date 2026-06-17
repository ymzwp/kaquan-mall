package com.book.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.book.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;

import java.math.BigDecimal;

@Mapper
public interface UserMapper extends BaseMapper<User> {

    /**
     * 更新用户余额（原子操作，防止并发超扣）
     */
    @Update("UPDATE user SET balance = balance + #{amount} WHERE id = #{userId}")
    int addBalance(@Param("userId") Integer userId, @Param("amount") BigDecimal amount);
}
