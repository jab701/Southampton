#include "KeyboardMap.h"

KeyboardMap::KeyboardMap()
{
	this->m_KeyMap.clear();
}
KeyboardMap::~KeyboardMap()
{
	this->m_KeyMap.clear();
}
void KeyboardMap::Clear()
{
	this->m_KeyMap.clear();
}
bool KeyboardMap::SetDown(int KeyCode)
{
	KeyMapType::iterator iter = this->m_KeyMap.find(KeyCode);

	if (iter != this->m_KeyMap.end()) 
	{ // Keyboard Character was found
		if (iter->second == false)
		{
			iter->second = true;
			return true;
		}
		else
		{
			return false;
		}
	}
	else
	{ // Keyboard Character was not found, add it and set it to true

		this->m_KeyMap.insert(std::pair<int, bool>(KeyCode, true));
		return true;
	}
}
bool KeyboardMap::SetUp(int KeyCode)
{
	KeyMapType::iterator iter = this->m_KeyMap.find(KeyCode);

	if (iter != this->m_KeyMap.end()) 
	{ // Keyboard Character was found
		if (iter->second == true)
		{
			iter->second = false;
			return true;
		}
		else
		{
			return false;
		}
	}
	else
	{ // Keyboard Character was not found, add it and set it to true

		this->m_KeyMap.insert(std::pair<int, bool>(KeyCode, false));
		return true;
	}
}