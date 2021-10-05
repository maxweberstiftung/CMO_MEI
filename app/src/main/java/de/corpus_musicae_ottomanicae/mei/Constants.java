package de.corpus_musicae_ottomanicae.mei;

public class Constants {
    public static final String MEI_NS = "http://www.music-encoding.org/ns/mei";
    public static final String XLINK_NS = "http://www.w3.org/1999/xlink";

    public enum PName {
        c, d, e, f, g, a, b
    }

    /**
     * Arel-Ezgi-Uzdilek accidentals
     */
    public enum AEUAccidental {
        bms, kms, bs, ks, kf, bf, kmf, bmf, n
    }

    /**
     * Commen Western Music Notation accidentals
     */
    public enum CWMNAccidental {
        s, f, ss, ff, n, su, sd, fu, fd, x
    }
}
