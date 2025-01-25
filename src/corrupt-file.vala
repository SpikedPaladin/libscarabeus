namespace Scarabeus {
    
    public class CorruptFile : Object {
        public string path { get; set; }
        public uint8[] sample_bytes { get; set; }
        public uint8[] main_bytes { get; set; }
        public string sample_content { get; set; }
        public string main_content { get; set; }
        
        public CorruptFile(string path, uint8[] main_bytes, uint8[] sample_bytes) {
            this.path = path;
            this.main_bytes = main_bytes;
            this.sample_bytes = sample_bytes;
            
            var main_hex = bytes_to_hex(main_bytes);
            var sample_hex = bytes_to_hex(sample_bytes);
            
            main_content = get_diff(main_hex, sample_hex);
            sample_content = get_diff(sample_hex, main_hex);
        }
        
        private string bytes_to_hex(uint8[] bytes) {
            var result = "";
            
            foreach (var byte in bytes) {
                result += "%02X ".printf(byte);
            }
            
            return result;
        }
        
        private string get_diff(string str1, string str2) {
            int len1 = str1.length;
            int len2 = str2.length;
            int min_len = int.min(len1, len2);
            
            int prefix_len = 0;
            while (prefix_len < min_len && str1[prefix_len] == str2[prefix_len]) {
                prefix_len++;
            }
            
            int suffix_len = 0;
            while (suffix_len < min_len - prefix_len && str1[len1 - suffix_len - 1] == str2[len2 - suffix_len - 1]) {
                suffix_len++;
            }
            
            StringBuilder result = new StringBuilder();
            
            result.append(str1.substring(0, prefix_len));
            
            for (int i = prefix_len; i < len1 - suffix_len; i++) {
                result.append("<u>").append_unichar(str1[i]).append("</u>");
            }
            
            result.append(str1.substring(len1 - suffix_len));
            
            return result.str;
        }
    }
}