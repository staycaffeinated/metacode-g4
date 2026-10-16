<#include "/common/Copyright.ftl">
package ${ModelTestFixtures.packageName()};

import ${EntityResource.fqcn()};

import java.util.ArrayList;
import java.util.List;

public class ${ModelTestFixtures.className()} {

    public static ${EntityResource.className()} oneWithResourceId() {
        ${EntityResource.className()} item = new ${EntityResource.className()}();
        item.setResourceId("abcdefghij12");
        item.setText("sample text");
        return item;
    }

    public static ${EntityResource.className()} oneWithoutResourceId() {
        ${EntityResource.className()} item = new ${EntityResource.className()}();
        item.setText("sample text");
        return item;
    }

    public static ${EntityResource.className()} copyOf(${EntityResource.className()} source) {
        ${EntityResource.className()} copy = new ${EntityResource.className()}();
        copy.setResourceId(source.getResourceId());
        copy.setText(source.getText());
        return copy;
    }

    public static List<${EntityResource.className()}> allItems() {
        List<${EntityResource.className()}> list = new ArrayList<>();
        list.add(oneWithResourceId());
        ${EntityResource.className()} second = new ${EntityResource.className()}();
        second.setResourceId("bcdefghijk34");
        second.setText("another text");
        list.add(second);
        return list;
    }
}
