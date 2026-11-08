package util;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

/**
 * Tiện ích gửi email qua Gmail SMTP (hỗ trợ xác thực bằng App Password).
 */
public class EmailUtils {

    private static final Properties configProps = new Properties();

    static {
        loadConfig();
    }

    public static synchronized void loadConfig() {
        // 1. Thử đọc từ classpath (classes/email.properties)
        try (InputStream is = EmailUtils.class.getClassLoader().getResourceAsStream("email.properties")) {
            if (is != null) {
                configProps.load(is);
            }
        } catch (Exception e) {
            System.err.println("[EmailUtils] Không thể đọc file email.properties từ classpath: " + e.getMessage());
        }

        // 2. Thử đọc trực tiếp từ thư mục src/java/email.properties nếu đang chạy local
        java.io.File srcFile = new java.io.File("FreshFruitStore-main/src/java/email.properties");
        if (srcFile.exists()) {
            try (java.io.FileInputStream fis = new java.io.FileInputStream(srcFile)) {
                configProps.load(fis);
            } catch (Exception ignored) {
            }
        }
    }

    public static String getSenderEmail() {
        return configProps.getProperty("email.sender.address", "tungdonhat8@gmail.com").trim();
    }

    public static String getSenderPassword() {
        String pass = configProps.getProperty("email.sender.password", "");
        return pass != null ? pass.replaceAll("\\s+", "").trim() : "";
    }

    public static String getSenderName() {
        return configProps.getProperty("email.sender.name", "FreshFruit Store").trim();
    }

    public static String getSmtpHost() {
        return configProps.getProperty("email.smtp.host", "smtp.gmail.com").trim();
    }

    public static String getSmtpPort() {
        return configProps.getProperty("email.smtp.port", "587").trim();
    }

    /**
     * Gửi mã OTP khôi phục mật khẩu qua Gmail.
     *
     * @param recipientEmail Địa chỉ email người nhận
     * @param recipientName  Tên người nhận (nếu có)
     * @param otpCode        Mã OTP (ví dụ: 6 chữ số)
     * @return true nếu gửi thành công, false nếu thất bại
     */
    public static boolean sendOtpEmail(String recipientEmail, String recipientName, String otpCode) {
        loadConfig(); // Luôn nạp cấu hình mới nhất mỗi lần gửi
        if (recipientEmail == null || recipientEmail.trim().isEmpty() || otpCode == null) {
            return false;
        }

        final String fromEmail = getSenderEmail();
        final String fromPassword = getSenderPassword();
        final String senderName = getSenderName();

        // Luôn in ra console server để hỗ trợ debug/kiểm thử
        System.out.println("==================================================");
        System.out.println("[FreshFruitStore] Gửi mã xác nhận OTP tới: " + recipientEmail);
        System.out.println("[FreshFruitStore] >>> MÃ OTP: " + otpCode + " <<<");
        System.out.println("==================================================");

        if (fromPassword.isEmpty()) {
            System.err.println("[EmailUtils] CHƯA ĐIỀN MẬT KHẨU ỨNG DỤNG GMAIL (email.sender.password trong email.properties)!");
            System.err.println("[EmailUtils] Vui lòng tạo App Password tại https://myaccount.google.com/apppasswords và điền vào email.properties");
            return false;
        }

        Properties mailProps = new Properties();
        mailProps.put("mail.smtp.host", getSmtpHost());
        mailProps.put("mail.smtp.port", getSmtpPort());
        mailProps.put("mail.smtp.auth", "true");
        mailProps.put("mail.smtp.starttls.enable", "true");
        mailProps.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");
        mailProps.put("mail.smtp.connectiontimeout", "10000"); // 10 giây timeout
        mailProps.put("mail.smtp.timeout", "10000");

        Session session = Session.getInstance(mailProps, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(fromEmail, fromPassword);
            }
        });

        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromEmail, senderName, StandardCharsets.UTF_8.name()));
            message.setRecipient(Message.RecipientType.TO, new InternetAddress(recipientEmail.trim()));
            message.setSubject("[FreshFruit Store] Mã xác nhận đặt lại mật khẩu của bạn", StandardCharsets.UTF_8.name());

            String displayName = (recipientName != null && !recipientName.trim().isEmpty())
                    ? recipientName.trim()
                    : "Quý khách";

            String htmlBody = buildOtpHtmlBody(displayName, otpCode);
            message.setContent(htmlBody, "text/html; charset=UTF-8");

            Transport.send(message);
            System.out.println("[EmailUtils] Đã gửi email OTP thành công tới " + recipientEmail);
            return true;

        } catch (MessagingException me) {
            System.err.println("[EmailUtils] Lỗi khi gửi email qua Gmail SMTP: " + me.getMessage());
            me.printStackTrace();
            return false;
        } catch (Exception e) {
            System.err.println("[EmailUtils] Lỗi không xác định khi tạo email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    private static String buildOtpHtmlBody(String name, String otp) {
        return "<!DOCTYPE html>"
                + "<html>"
                + "<head><meta charset=\"UTF-8\"></head>"
                + "<body style=\"margin:0; padding:24px; background-color:#f8fafc; font-family:'Segoe UI',Roboto,Helvetica,Arial,sans-serif; color:#1e293b;\">"
                + "  <div style=\"max-width:520px; margin:0 auto; background:#ffffff; border-radius:16px; overflow:hidden; box-shadow:0 10px 25px rgba(0,0,0,0.06); border:1px solid #e2e8f0;\">"
                + "    <div style=\"background:linear-gradient(135deg, #16a34a 0%, #15803d 100%); padding:28px 24px; text-align:center; color:#ffffff;\">"
                + "      <div style=\"font-size:24px; font-weight:800; letter-spacing:-0.5px;\">FreshFruit Store</div>"
                + "      <div style=\"font-size:13px; opacity:0.9; margin-top:4px;\">Cửa Hàng Trái Cây Tươi Cao Cấp</div>"
                + "    </div>"
                + "    <div style=\"padding:32px 28px;\">"
                + "      <h2 style=\"font-size:20px; font-weight:700; color:#0f172a; margin-top:0; margin-bottom:12px;\">Khôi phục mật khẩu</h2>"
                + "      <p style=\"font-size:14px; line-height:1.6; color:#475569; margin:0 0 20px;\">"
                + "        Xin chào <strong>" + escapeHtml(name) + "</strong>,<br>"
                + "        Chúng tôi nhận được yêu cầu lấy lại mật khẩu cho tài khoản của bạn tại <strong>FreshFruit Store</strong>. "
                + "        Dưới đây là mã xác thực OTP dùng để đặt lại mật khẩu:"
                + "      </p>"
                + "      <div style=\"background:#f0fdf4; border:2px dashed #16a34a; border-radius:12px; padding:20px; text-align:center; margin:24px 0;\">"
                + "        <div style=\"font-size:12px; font-weight:600; text-transform:uppercase; letter-spacing:1px; color:#16a34a; margin-bottom:8px;\">MÃ XÁC NHẬN OTP CỦA BẠN</div>"
                + "        <div style=\"font-size:36px; font-weight:800; letter-spacing:10px; color:#15803d; font-family:'Courier New',monospace;\">" + escapeHtml(otp) + "</div>"
                + "        <div style=\"font-size:13px; color:#64748b; margin-top:10px;\">Mã có hiệu lực trong vòng <strong style=\"color:#dc2626;\">5 phút</strong></div>"
                + "      </div>"
                + "      <div style=\"background:#fffbeb; border-left:4px solid #f59e0b; padding:14px; border-radius:6px; font-size:13px; color:#92400e; line-height:1.5;\">"
                + "        <strong>Lưu ý bảo mật:</strong> Tuyệt đối không chia sẻ mã này cho bất kỳ ai. Nếu bạn không gửi yêu cầu này, vui lòng bỏ qua email và tài khoản của bạn vẫn an toàn."
                + "      </div>"
                + "    </div>"
                + "    <div style=\"background:#f8fafc; padding:18px 24px; text-align:center; font-size:12px; color:#94a3b8; border-top:1px solid #e2e8f0;\">"
                + "      Email này được gửi tự động từ hệ thống FreshFruit Store. Vui lòng không phản hồi trực tiếp email này."
                + "    </div>"
                + "  </div>"
                + "</body>"
                + "</html>";
    }

    private static String escapeHtml(String text) {
        if (text == null) return "";
        return text.replace("&", "&amp;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;")
                   .replace("'", "&#39;");
    }
}
