package com.umugram.Tfg.repositories;

import com.umugram.Tfg.domain.User;

import java.util.List;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;


public interface UserRepository extends JpaRepository<User, Long> {
	User findByUsername(String username);

	@Query("SELECT f FROM User u JOIN u.followers f WHERE u.id = :userId")
	List<User> findFollowersById(@Param("userId") Long userId);

	@Query("SELECT f FROM User u JOIN u.following f WHERE u.id = :userId")
	List<User> findFollowingById(@Param("userId") Long userId);

	@EntityGraph(value = "uploadPosts", type = EntityGraph.EntityGraphType.LOAD)
	User findWithPostsByUsername(String username);

}

