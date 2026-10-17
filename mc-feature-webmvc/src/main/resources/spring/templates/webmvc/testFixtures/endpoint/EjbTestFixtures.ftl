<#include "/common/Copyright.ftl">
package ${EjbTestFixtures.packageName()};

import ${Entity.fqcn()};

import java.util.ArrayList;
import java.util.List;

public class ${EjbTestFixtures.className()} {

    public static ${Entity.className()} oneWithResourceId() {
        ${Entity.className()} item = new ${Entity.className()}();
        item.setResourceId("abcdefghijklmnopqrstuvwxyz1");
        item.setText("sample text");
        return item;
    }

    public static List<${Entity.className()}> allItems() {
        List<${Entity.className()}> list = new ArrayList<>();
        list.add(oneWithResourceId());
        ${Entity.className()} second = new ${Entity.className()}();
        second.setResourceId("bcdefghijklmnopqrstuvwxyz12");
        second.setText("another text");
        list.add(second);
        return list;
    }
}
