package com.umugram.Tfg.repositories;

import com.umugram.Tfg.domain.Post;
import com.umugram.Tfg.domain.LivePost;
import com.umugram.Tfg.domain.User;
import com.umugram.Tfg.repositories.custom.CustomPostRepository;

import jakarta.transaction.Transactional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.HashSet;
import java.util.List;


public interface PostRepository extends JpaRepository<Post, Long>, CustomPostRepository {
    @Query(name = "Post.findAllShortsComments")
    List<Post> findAllShortsComments();

    @Query("SELECT Post FROM Post Post WHERE Post.id < :id")
    HashSet<Post> findAllLessUsers2(@Param("id") Long id);

    @Query(name = "LivePost.findAllActiveStreams")
    List<LivePost> findAllActiveStreams(@Param("user") User user);

    @Transactional
    @Modifying
    @Query("DELETE FROM Post Post WHERE Post.caption = :caption")
    void deleteByCaption(@Param("caption") String caption);

    List<Post> findByUser(User user);

}
