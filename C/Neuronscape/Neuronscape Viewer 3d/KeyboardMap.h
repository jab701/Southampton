#ifndef KEYBOARDMAP_H
#define KEYBOARDMAP_H

#include <wx/wx.h>
#include <map>
#include <stdint.h>

typedef std::map<int, bool> KeyMapType;

class KeyboardMap
{
public:
	KeyboardMap();
	~KeyboardMap();

	void Clear();
	bool SetDown(int KeyCode);
	bool SetUp(int KeyCode);

private:
	KeyMapType m_KeyMap;
};

#endif