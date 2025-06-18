package com.umugram.Tfg;

import com.umugram.Tfg.domain.*;
import com.umugram.Tfg.repositories.*;
import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.*;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.LocalDate;

@SpringBootTest(classes = TfgApplication.class)
public class CommentRepositoryTests {

    @Autowired
    private PostRepository postRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private CommentRepository commentRepository;

    User manuel, paco, maria;

    @BeforeEach
    void init() {
    	
        userRepository.deleteAll();
        commentRepository.deleteAll();
        postRepository.deleteAll();

        manuel = new User("Manuel1", "contraseña2", LocalDate.of(2003, 3, 4), "manuel1@gmail.com");
        Profile manuProfile = new Profile("El manueh");
        manuProfile.setDescription("I love ice scream in the morning");
        manuProfile.setWebsite("elmanueh.es");
        manuel.setProfile(manuProfile);

        paco = new User("Paco", "contraseña2", LocalDate.of(1998, 5, 12), "paco1@gmail.com");
        Profile pacoProfile = new Profile("Paco Sanchéz");
        pacoProfile.setDescription("I hate global injustices");
        pacoProfile.setAvatar_url("https://www.bobesponjaweb.com/wp-content/uploads/2014/11/Calamardo-2.jpg");
        paco.setProfile(pacoProfile);

        maria = new User("Maria", "contraseña3", LocalDate.of(2001, 8, 20), "maria@hotmail.com");
        Profile mariaProfile = new Profile("Marie");
        mariaProfile.setDescription("I love the sea");
        maria.setProfile(mariaProfile); 

        userRepository.save(manuel);
        userRepository.save(paco);
        userRepository.save(maria);
    }

    @Test
    void commentPost()
    {
        // Arrange
        Post post = new PhotoPost("Manuel's post","https://www.google.com");
        post.setDescription("This is a post of Manuel");
        postRepository.saveAndFlush(post);
        manuel.uploadPosts(post);
        userRepository.saveAndFlush(manuel);

        // Act
        Comment commentPaco = new Comment("Very nice", paco, post);
        commentRepository.saveAndFlush(commentPaco);

        // Assert
        Comment commentPaco2 = commentRepository.findById(commentPaco.getId()).orElseGet(() -> null);
        assertNotNull(commentPaco2);
    }

    @Test
    void replyComment()
    {
        // Arrange
        Post post = new PhotoPost("Manuel's post","https://www.google.com");
        post.setDescription("This is a post of Manuel");
        postRepository.saveAndFlush(post);
        manuel.uploadPosts(post);
        userRepository.saveAndFlush(manuel);

        Comment commentPaco = new Comment("Very nice", paco, post);
        commentRepository.saveAndFlush(commentPaco);

        // Act
        Comment commentMaria = new Comment("Yeah, It's incredible", maria, post);
        commentMaria.setReplyTo(commentPaco);
        commentRepository.saveAndFlush(commentMaria);

        // Assert
        Comment commentMaria2 = commentRepository.findById(commentMaria.getId()).orElseGet(() -> null);
        assertNotNull(commentMaria2);
    }

    @Test
    void replyCommentAfterDeleteParent() {
        // Arrange
        Post post = new PhotoPost("Manuel's post","https://www.google.com");
        post.setDescription("This is a post of Manuel");
        postRepository.saveAndFlush(post);
        manuel.uploadPosts(post);
        userRepository.saveAndFlush(manuel);

        Comment commentPaco = new Comment("Very nice", paco, post);
        commentRepository.saveAndFlush(commentPaco);

        Comment commentMaria = new Comment("Yeah, It's incredible", maria, post);
        commentMaria.setReplyTo(commentPaco);
        commentRepository.saveAndFlush(commentMaria);

        // Act
        commentRepository.delete(commentPaco);

        // Assert
        Comment commentMaria2 = commentRepository.findById(commentMaria.getId()).orElseGet(() -> null);
        assertNull(commentMaria2);
    }
}
