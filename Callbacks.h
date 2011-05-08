#ifndef _CALLBACKS_H_
#define _CALLBACKS_H_

int term_putglyph_translate(const uint32_t chars[], int  width, VTermPos pos, void *user);

void term_putglyph(const unsigned int *chars, int  width, VTermPos pos, void *user);

int term_movecursor(VTermPos pos, VTermPos oldpos, int visible, void *user);

int term_copyrect(VTermRect dest, VTermRect src, void *user);

int term_copycell(VTermPos destpos, VTermPos srcpos, void *user);

int term_erase(VTermRect rect, void *user);

int term_setpenattr(VTermAttr attr, VTermValue *val, void *user);

int term_settermprop(VTermProp prop, VTermValue *val, void *user);

int term_setmousefunc(VTermMouseFunc func, void *data, void *user);

int term_bell(void *user);

#endif /* _CALLBACKS_H_ */
