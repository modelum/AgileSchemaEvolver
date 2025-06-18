package com.umugram.Tfg.repositories;

import com.umugram.Tfg.domain.Comment;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CommentRepository extends JpaRepository<Comment, Long> {

}
