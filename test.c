unsigned int memtest(unsigned int start, unsigned int end) {
    char flg486 = 0;
    unsigned int eflg, cr0, i;

    /* 386か、486以降なのか日確認 */
    eflg = io_load_eflags();
    eflg |= EFLAGS_AC_BIT; /* AC-bit = 1 */
    io_store_eflags(eflg);
    eflg = io_load_eflags();
    if ((eflg & EFLAGS_AC_BIT) != 0) { /* 386ではAC=１にしても自動で０に戻ってしまう */
        flg486 = 1;
    }
    eflg &= ~EFLAGS_AC_BIT; /* AC-bit = 0 */
    io_store_eflags(eflg);

    if (flg486 != 0) {
        cr0 = load_cr0();
        cr0 |= CR0_CACHE_DISABLE; /* キャッシュ禁止 */
        store_cr0(cr0);
    }

    i = memtest_sub(start, end);

    if (flg486 != 0) {
        cr0 = load_cr0();
        cr0 &= ~CR0_CACHE_DISABLE; /* キャッシュ許可 */
        store_cr0(cr0);
    }
    return i;
}

unsigned int memtest_sub(unsigned int start, unsigned int end) {
    unsigned int i, *p, old, pat0 = 0xaa55aa55, pat1 = 0x55aa55aa;
    for (i = start; i <= end; i += 0x1000) {
        p = (unsigned int *)(i + 0xffc);
        old = *p; /* いじる前の値を覚えておく */
        *p = pat0;  /* 試しに書いてみる */
        *p ^= 0xffffffff; /* そしてそれを反転してみる */
        if (*p != pat1) { /* 反転結果になったか */
not_memory:
            *p = old;
            break;
        }
        *p ^= 0xffffffff; /* もう一度反転してみる */
        if (*p != pat0) { /* もとに戻ったか? */
            goto not_memory;
        }
        *p = old; /* いじった値をもとに戻す */
    }
    return i;
}
