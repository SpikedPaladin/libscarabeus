namespace Scarabeus {
    
    public class Scanner : Object {
        public string main_path { get; set; }
        public string sample_path { get; set; }
        public int context_size { get; set; }
        
        public Scanner(string main_path, string sample_path, int context_size) {
            Object(main_path: main_path, sample_path: sample_path, context_size: context_size);
        }
        
        public CorruptFile[] find_corrupted(Cancellable? cancellable = null) throws Error {
            CorruptFile[] result = {};
            
            var main = File.new_for_commandline_arg(main_path);
            var sample = File.new_for_path(sample_path);
            var enumerator = main.enumerate_children(FileAttribute.STANDARD_NAME, 0, cancellable);
            
            FileInfo file_info;
            while ((file_info = enumerator.next_file()) != null) {
                var child = enumerator.get_child(file_info);
                var sample_child = sample.get_child(file_info.get_name());
                if (!sample_child.query_exists()) continue;
                
                var corrupt_file = get_corrupt_file(child.get_path(), sample_child.get_path(), cancellable);
                if (corrupt_file != null) {
                    result += corrupt_file;
                }
		    }
            
            return result;
        }
        
        public CorruptFile? get_corrupt_file(string main_path, string sample_path, Cancellable? cancellable = null) {
            try {
                var main_file = File.new_for_path(main_path);
                var sample_file = File.new_for_path(sample_path);
                
                var stream1 = main_file.read(cancellable);
                var stream2 = sample_file.read(cancellable);
                
                var buffer1 = new uint8[4096];
                var buffer2 = new uint8[4096];
                
                ssize_t read1 = 0, read2 = 0;
                int offset = 0;
                bool found_diff = false;
                
                while ((read1 = stream1.read(buffer1, cancellable)) > 0 && (read2 = stream2.read(buffer2, cancellable)) > 0) {
                    for (int i = 0; i < ssize_t.min(read1, read2); i++) {
                        if (buffer1[i] != buffer2[i]) {
                            offset += i;
                            found_diff = true;
                            break;
                        }
                    }
                    if (found_diff)
                        break;
                    
                    offset += (int) read1;
                }
                
                if (!found_diff)
                    return null;
                
                stream1.seek(offset - context_size, SeekType.SET, cancellable);
                stream2.seek(offset - context_size, SeekType.SET, cancellable);
                
                var bytes1 = new uint8[context_size * 2];
                var bytes2 = new uint8[context_size * 2];
                
                read1 = stream1.read(bytes1, cancellable);
                read2 = stream2.read(bytes2, cancellable);
                
                return new CorruptFile(main_path, bytes1, bytes2);
            } catch (Error e) {
                return null;
            }
        }
    }
}